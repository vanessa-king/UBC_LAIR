function [masks_stack, masks_combined_stack, figMasks, comment] = maskDirectionalB(data, n, V_reduced, imageV, connected, startPoint, endPoint, width, bin_size, bin_sep)
% MASKDIRECTIONAL Create directional masks and combine them
% This function is a wrapper that creates directional masks and optionally
% combines them using specified binning parameters.
%
% Arguments:
%   data            2D or 3D array containing the data
%   n               slice number: optional for 3D dataset only 
%   connected       logical flag for side connectivity (default false) 
%   startPoint      [x1,y1] start point coordinates
%   endPoint        [x2,y2] end point coordinates
%   bin_size        Number of slices to combine per bin
%   bin_sep         Separation between start of each bin
%
% Returns:
%   masks           3D array of original masks (data_dim x data_dim x L)
%   masks_combined  3D array of combined masks (if bin parameters provided)
%                   or empty array (if no bin parameters)
%   figMasks        figure handle of mask figure
%   comment         String containing function call information
%function [outputArg1,outputArg2] = untitled(inputArg1,inputArg2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Created by M. Altthaler 07-2025 (based on D. Chens function) 
% now features GUI based selection of the ROI and subsequently the masks
% are created from the ROI.

arguments (Input)
    data        
    n           {mustBePositive}    =[]     % optional, only for 3D data
    V_reduced   {mustBeNumeric}     =[]     % optional, only for 3D data
    imageV      {mustBeNumeric}     =[]     % optional, only for 3D data
    connected                       =[]     % optional, only for 3D data
    startPoint  {mustBeNumeric}     =[]     % optional, to reproduce ROI
    endPoint    {mustBeNumeric}     =[]     % optional, to reproduce ROI
    width       {mustBeNumeric}     =[]     % optional, to reproduce ROI    
    bin_size    {mustBeNumeric}     =[]     % optional, to (re)produce combined masks
    bin_sep     {mustBeNumeric}     =[]     % optional, to (re)produce combined masks
end

arguments (Output)
    masks_stack             
    masks_combined_stack
    figMasks
    comment
end


% ensure 2D image and dispay it
[data_slice, imN, V_actual] = dataSlice2D(data,n,V_reduced,imageV);

% draw and move ROI on image -> confirm to continue / reproduce ROI 
[startPoint, endPoint, width] = drawROIlineWidth(data_slice,startPoint, endPoint, width); 

% create masks_stack from ROI
[masks_stack] = generateMaskStack(data_slice, startPoint, endPoint, width, connected);

% Only combine masks if both bin parameters are provided 
if ~isempty(bin_size) && ~isempty(bin_sep) 
    [masks_combined_stack, idx] = combineMasks(masks_stack, bin_size, bin_sep);
    %plot masks_stack from ROI & combined_stack
    [figMasks] = plotCombineMasks(masks_stack,masks_combined_stack,startPoint,endPoint,bin_size, bin_sep);
else
    masks_combined_stack = [];
    %plot only masks_stack from ROI
    [figMasks] = plotMasks(masks_stack,startPoint,endPoint);
end

% log comment of function execution
comment = sprintf("maskDirectionalB() execution parameters || data_slice: imN = %s, V_actual  %s | selected ROI: startPoint = %s, endPoint = %s, width = %s " + ...
    "| masks_stack: size(x,y,L) = %s | masks_combined_stack: size(x,y,B) = %s" ...
    ,mat2str(imN),mat2str(V_actual),mat2str(startPoint),mat2str(endPoint),mat2str(width),mat2str(size(masks_stack)),mat2str(size(masks_combined_stack)));

end

%% main helper functions

function [ROIstartPoint, ROIendPoint, ROIwidth] = drawROIlineWidth(data_slice, startPoint, endPoint, width)

    arguments 
        data_slice                                          % required to init and get limits
        startPoint  {mustBeNumeric, mustBePositive} =[]     % optional, to reproduce ROI
        endPoint    {mustBeNumeric, mustBePositive} =[]     % optional, to reproduce ROI
        width       {mustBeNumeric, mustBePositive} =[]     % optional, to reproduce ROI 
    end
    
    if ~isempty(startPoint) && ~isempty(endPoint) && ~isempty(width)
        disp("ROI selection bypassed via complete presets -> reproduce ROI")
        byPassBool = 1;
    else
        byPassBool = 0;
    end

    % initialize figure for selection:
    f = figure('Name','Select region for mask');
    imagesc(permute(data_slice,[2 1]));
    ax = gca;
    setGraphLayout("2D_Image");
    %overwrite titel string: 
    ax.Title.String = "Confirm selection with ENTER key";
    hold on

    % calc size limits based on data
    szLimits = size(data_slice);
    % Initialize start and end points if not provided
    if isempty(startPoint)
        startPoint = round(szLimits ./ 3); 
    end
    if isempty(endPoint)
        endPoint = round(szLimits ./ 3 * 2); 
    end
    if isempty(width)
        width = 5; 
    end

    %check limits 
    corners = calculateShadedCorners(startPoint, endPoint, width);
    if checkPointsInRange(szLimits, startPoint, endPoint, corners)
        % Draw the main line ROI with shaded area
        % allows dragging and returns the final selected ROIs
        [mainLineROI, widthLineA, ~] = drawShadedROI(startPoint, endPoint, width,szLimits, byPassBool);
    else 
        disp("Initial settings yield out of bound points!")
    end   
    
    if isvalid(f)
        % assing ROIstartPoint, ROIendPoint, ROIwidth based on returned ROI
        % and round values to clip to pixel coordinates
        ROIstartPoint = round(mainLineROI.Position(1,:));
        ROIendPoint = round(mainLineROI.Position(2,:));
        ROIwidth = round(norm(widthLineA.Position(2,:)-widthLineA.Position(1,:)));
    else
        ROIstartPoint = [];
        ROIendPoint = [];
        ROIwidth = [];
        disp("Selection aborted!")
    end

    

end

function [maskStack] = generateMaskStack(data_slice, startPoint, endPoint, width, connected)
    if isempty(connected)
        connected = 0;
    end
    % calc size
    sz = size(data_slice);
    % make main line as a mainLineMask
    if connected == 0
        mainLineMask = createLineSegmentMask(sz, startPoint, endPoint);
    elseif connected == 1
        mainLineMask = createLineSegmentMask_connected(sz, startPoint, endPoint);
    end
    % use loop over find(mainLineMask) to make perp masks of width  
    % Find all points along the main line and assing their [x y] coordinates to mainLinePoints
    [mainLineMask_x, mainLineMask_y] = find(mainLineMask);
    mainLinePoints =  [mainLineMask_x, mainLineMask_y];
    mainLineLength = length(mainLineMask_x);
    % calculate perpendicular vector for small mask endpoints & initialize
    % maskStack with correct dimensions
    [perpVector] = calculatePerpendicularVector(startPoint, endPoint, width);
    maskStack = false(sz(1), sz(2), mainLineLength);
    %loop over each point and make the submask
    for n = 1:mainLineLength
        [perpendicularStart, perpendicularEnd] = calculatePerpendicularLinePoints(perpVector, mainLinePoints(n,:));
        maskStack(:,:,n) = createLineSegmentMask(sz, perpendicularStart, perpendicularEnd);
    end
    

end

function [M2,idx] = combineMasks(M1, bin_size, bin_sep, omit_incomplete)
    %COMBINEMASKS Combine 3D mask array into binned mask array
    %
    % Arguments:
    %   M1              3D logical array (Image_x, Image_y, num_lines)
    %   bin_size        Number of slices to combine per bin
    %   bin_sep         Separation between start of each bin
    %   omit_incomplete Optional. If true, omit incomplete last bin (default: false)
    %
    % Returns:
    %   M2              3D logical array (Image_x, Image_y, num_bins)
    %
    % Example:
    %   M2 = combineMasks(M1, 3, 2, true)  % Overlapping bins, skip incomplete
    %   M2 = combineMasks(M1, 3, 4)        % Non-overlapping bins with gap
    %
    % Notes:
    %   - bin_size must be <= number of slices in M1
    %   - bin_sep can be < bin_size (overlap) or > bin_size (gap)
    %   - Last bin might be incomplete unless omit_incomplete is true
    %   - Warning is issued when incomplete bin is included
    %
    % August 2024 - Dong Chen
    
    % Input validation
    assert(ndims(M1) == 3, 'Input mask must be 3D array');
    assert(size(M1,3) > 1, 'Input mask must have multiple slices');
    assert(islogical(M1), 'Input mask must be logical array');
    assert(bin_size > 0 && bin_size <= size(M1,3), ...
        'bin_size must be positive and <= number of slices');
    assert(bin_sep > 0, 'bin_sep must be positive');
    
    if nargin < 4
        omit_incomplete = true;
    end
    
    % Calculate number of complete bins
    num_slices = size(M1,3);
    num_complete_bins = floor((num_slices - bin_size) / bin_sep) + 1;
    
    % Create index array for complete bins
    idx = zeros(bin_size, num_complete_bins);
    for i = 1:num_complete_bins
        start = (i-1)*bin_sep + 1;
        idx(:,i) = start:(start+bin_size-1);
    end
    
    % Check for incomplete last bin
    remaining_start = (num_complete_bins*bin_sep) + 1;
    if remaining_start <= num_slices && ~omit_incomplete
        remaining_size = num_slices - remaining_start + 1;
        if remaining_size > 0
            warning(['Last bin will be incomplete with only ' ...
                num2str(remaining_size) ' slices instead of ' ...
                num2str(bin_size) ' slices']);
            
            % Add indices for incomplete bin
            last_idx = zeros(bin_size, 1);
            last_idx(1:remaining_size) = remaining_start:num_slices;
            idx = cat(3, idx, last_idx);
        end
    end
    
    % Initialize output array
    M2 = false(size(M1,1), size(M1,2), size(idx,2));
    
    % Combine masks using indices
    for i = 1:size(idx,2)
        valid_idx = idx(:,i);
        valid_idx = valid_idx(valid_idx > 0);  % Remove zero padding from incomplete bin
        M2(:,:,i) = any(M1(:,:,valid_idx), 3);
    end
end 

%% drawROIlineWidth() helper functions

function [lineROI] = drawLineROI(startPoint, endPoint, color)
    lineROI = images.roi.Line(gca,'Position', [startPoint; endPoint], ...
                          'Color', color);
end

function [isInRange] = checkPointsInRange(szLimits, startPoint, endPoint, corners)
    % Check if startPoint, endPoint, and all corners are within the image size limits
    isInRange = all(startPoint >= [1, 1]) && all(startPoint <= szLimits) && ...
                all(endPoint >= [1, 1]) && all(endPoint <= szLimits) && ...
                all(corners(:, 1) >= 1) && all(corners(:, 1) <= szLimits(1)) && ...
                all(corners(:, 2) >= 1) && all(corners(:, 2) <= szLimits(2));
end

function [corners] = calculateShadedCorners(startPoint, endPoint, width)
    % Calculate the direction vector of the line
    direction = endPoint - startPoint;

    % Normalize the direction vector
    normDirection = direction / norm(direction);

    % Calculate the perpendicular vector
    perpVector = [-normDirection(2), normDirection(1)] * (width / 2);

    % Calculate the corners of the shaded area
    corners = [
        startPoint + perpVector;  % Bottom left corner
        startPoint - perpVector;  % Top left corner
        endPoint - perpVector;    % Top right corner
        endPoint + perpVector      % Bottom right corner
    ];
end

function [corners] = calculateShadedCornersWithDynamicWidth(startPoint, endPoint, movedPoint)
    % Calculate the direction vector of the line
    direction = endPoint - startPoint;

    % Normalize the direction vector
    normDirection = direction / norm(direction);

    % Calculate the perpendicular vector
    perpVector = [-normDirection(2), normDirection(1)];

    % Calculate the projection of the fixedPoint onto the line
    lineToPoint = movedPoint - startPoint;
    projectionLength = dot(lineToPoint, normDirection);
    closestPointOnLine = startPoint + projectionLength * normDirection;

    % Calculate the distance from the fixed point to the closest point on the line
    distanceToMovedPoint = norm(movedPoint - closestPointOnLine);

    % Calculate the width as the distance to the fixed point
    width = distanceToMovedPoint*2;

    % Scale the perpendicular vector by half the width
    scaledPerpVector = perpVector * (width / 2);

    % Calculate the corners of the shaded area
    corners = [
        startPoint + scaledPerpVector;  % Bottom left corner
        startPoint - scaledPerpVector;  % Top left corner
        endPoint - scaledPerpVector;    % Top right corner
        endPoint + scaledPerpVector      % Bottom right corner
    ];
end

function [mainLineROI, widthLineA, widthLineB] = drawShadedROI(startPoint, endPoint, width, szLimits, bypassBool)
    % Calculate the corners of the shaded area
    corners = calculateShadedCorners(startPoint, endPoint, width);
    % Draw the shaded area
    shadedArea = images.roi.Polygon(gca,'Position',corners,'Color','r','FaceAlpha', 0.2, 'LineWidth',1,'InteractionsAllowed','none');
    % draw width marker lines
    widthLineA = drawLineROI(corners(1,:), corners(2,:),'r');
    widthLineB = drawLineROI(corners(3,:), corners(4,:),'r');
    % Draw main line on top
    hold on
    mainLineROI = drawLineROI(startPoint, endPoint,'b');
    
    if bypassBool == 1
        set(mainLineROI,'InteractionsAllowed','none');
        set(widthLineA,'InteractionsAllowed','none');
        set(widthLineB,'InteractionsAllowed','none');
        return
    end

    % add listners to widthLines and mainLine 
    addlistener(widthLineA, 'MovingROI', @(src, event) onWidthLineMove(src, event, mainLineROI,widthLineA, widthLineB, shadedArea, szLimits));
    addlistener(widthLineB, 'MovingROI', @(src, event) onWidthLineMove(src, event, mainLineROI,widthLineA, widthLineB, shadedArea, szLimits));
    addlistener(mainLineROI, 'MovingROI', @(src, event) onMainLineMove(src, event, widthLineA, widthLineB, shadedArea, szLimits));

    % Wait for Enter key press to confirm the final location
    waitForEnterKey(mainLineROI,widthLineA,widthLineB);
end

function [mainLineROI, widthLineA, widthLineB, shadedArea] = onMainLineMove(mainLineROI, event ,widthLineA,widthLineB, shadedArea,szLimits)
    % redraw ROI shapes when mainLineROI moves

    % assign current / previous position of event to start/endPoint    
        %currentPosition = event.CurrentPosition;
        %previousPosition = event.PreviousPosition;
    
    % assign current position -> startPoint & endPoint
    startPoint = event.CurrentPosition(1,:);
    endPoint = event.CurrentPosition(2,:);
    % calculate width from length of widthLineA
    width = norm(widthLineA.Position(2,:)-widthLineA.Position(1,:));
    % recalculate corner points of shaded area and check if these are in 
    % bounds of the data
    corners = calculateShadedCorners(startPoint, endPoint, width);
    if ~checkPointsInRange(szLimits,startPoint,endPoint,corners)
        %restore previous values
        %disp("Region of interest is out of bounds!")
        startPoint = event.PreviousPosition(1,:);
        endPoint = event.PreviousPosition(2,:);
        corners = calculateShadedCorners(startPoint, endPoint, width);
        %reset mainLineROI
        mainLineROI.Position(1,:) = startPoint;
        mainLineROI.Position(2,:) = endPoint;
    end
    % update shaded area
    shadedArea.Position = corners;
    % update width lines
    widthLineA.Position = [corners(1,:); corners(2,:)];
    widthLineB.Position = [corners(3,:); corners(4,:)]; 
end

function [widthLineA, widthLineB, shadedArea] = onWidthLineMove(~,event,mainLineROI,widthLineA,widthLineB,shadedArea,szLimits)
    % Callback function that executes when the line ROI is moved
    % assign current and previous position
        %currentPosition = event.CurrentPosition;
        %previousPosition = event.PreviousPosition;
    % Determine which endpoint moved
    if isequal(event.CurrentPosition(1, :),event.PreviousPosition(1, :))
        movedPoint = event.CurrentPosition(2, :);
        movedPointPrev = event.PreviousPosition(2, :);
    else
        movedPoint = event.CurrentPosition(1, :);
        movedPointPrev = event.PreviousPosition(1, :);
    end
   % recalculate corner points of shaded area (based on mainLineROI) and
   % check if these are in bounds of the data
        %startPoint = mainLineROI.Position(1,:);
        %endPoint = mainLineROI.Position(2,:);
    corners = calculateShadedCornersWithDynamicWidth(mainLineROI.Position(1,:), mainLineROI.Position(2,:), movedPoint);
    if ~checkPointsInRange(szLimits,mainLineROI.Position(1,:),mainLineROI.Position(2,:),corners)
        %restore previous values
        %disp("Region of interest is out of bounds!")
        corners = calculateShadedCornersWithDynamicWidth(mainLineROI.Position(1,:), mainLineROI.Position(2,:), movedPointPrev);
    end
    % update shaded area
    shadedArea.Position = corners;
    % update width lines
    widthLineA.Position = [corners(1,:); corners(2,:)];
    widthLineB.Position = [corners(3,:); corners(4,:)];

    %disp(['Line moved to: ', mat2str(currentPosition)]);
end

function waitForEnterKey(mainLineROI,widthLineA,widthLineB)
    % Create a figure for key press detection
    fig = gcf;  % Get the current figure handle 
    set(fig, 'KeyPressFcn',  @(src, event) keyPressCallback(src, event, mainLineROI,widthLineA,widthLineB)); % Set the KeyPressFcn to a custom callback function
    uiwait(fig); % Wait until the figure is closed or uiresume is called
end

function keyPressCallback(~, event, mainLineROI,widthLineA,widthLineB)
    if strcmp(event.Key, 'return') % Check if the Enter key was pressed
        uiresume; % Resume execution
        set(mainLineROI,'InteractionsAllowed','none');
        set(widthLineA,'InteractionsAllowed','none');
        set(widthLineB,'InteractionsAllowed','none');
    end
end

%% generateMaskStack() helper functions

function [mask] = createLineSegmentMask(imageSize, point1, point2)
%create a mask representing a line segment between two points
%   Returns a mask of imageSize which represents a line segment from point1 
%   to point2 using Bresenhams line algorythm. The function does not
%   accept point coordinates outside the limits of the image size.

%arguments:
%   imageSize   Size of the image [x_max, y_max]
%   point1      start point [x, y]
%   point2      end pont [x, y]

%returns: 
%   mask        logical mask representing the line between point1 and point2

% Nov. 2023 M. Altthaler

    arguments
        imageSize   {mustBeNumeric,mustBePositive}
        point1      {mustBeNumeric,mustBePositive}
        point2      {mustBeNumeric,mustBePositive}
    end
    
    % check if the point coordinates are within the image size:
    if point1(1)>imageSize(1)||point1(2)>imageSize(2)||point2(1)>imageSize(1)||point2(2)>imageSize(2)
        disp('Coordinates of point(s) exceed image size.')
        mask=[];
        return
    end
    %line interpolation
    %x(P1) -> x(P2)
    if point1(1)>point2(1)
        x = point1(1):-1:point2(1);
    else
        x = point1(1):point2(1);  
    end 
    %y(P1) -> y(P2)
    if point1(2)>point2(2)
        y = point1(2):-1:point2(2);
    else
        y = point1(2):point2(2);
    end
    
    %adjust x and y to match in length
    if length(y)> length(x)
        %stretch x and round to integer
        x = round(linspace(x(1),x(end),length(y)));
    elseif length(x)> length(y)
        %stretch y and round to integer
        y = round(linspace(y(1),y(end),length(x)));
    end
    
    % Initialize mask with zeros
    mask = zeros(imageSize);
    %set mask to 1 for all (x,y) coordinates
    for n = 1:length(x)
        mask(x(n),y(n)) = 1;
    end

end

function [mask] = createLineSegmentMask_connected(imageSize, point1, point2)
    mask = zeros(imageSize);
    
    % Round points to nearest integer
    x1 = round(point1(1));
    y1 = round(point1(2));
    x2 = round(point2(1));
    y2 = round(point2(2));
    
    % Calculate differences and steps
    dx = abs(x2 - x1);
    dy = abs(y2 - y1);
    
    % Store previous point
    prevX = x1;
    prevY = y1;
    
    % Set initial point
    mask(x1, y1) = 1;
    
    % Determine primary direction
    if dx > dy
        % Horizontal-dominant line
        xStep = sign(x2 - x1);
        x = x1;
        y = y1;
        
        % Calculate slope
        slope = (y2 - y1) / (x2 - x1);
        
        while x ~= x2
            x = x + xStep;
            y = y1 + slope * (x - x1);
            newY = round(y);
            
            % Check if new point shares a side with previous point
            if ~(x == prevX || newY == prevY)
                % Add intermediate point (Ax = Q1x, Ay = Q2y)
                mask(prevX, newY) = 1;
            end
            
            % Set current point
            if x >= 1 && x <= imageSize(1) && newY >= 1 && newY <= imageSize(2)
                mask(x, newY) = 1;
            end
            
            % Update previous point
            prevX = x;
            prevY = newY;
        end
    else
        % Vertical-dominant line
        yStep = sign(y2 - y1);
        x = x1;
        y = y1;
        
        % Calculate inverse slope
        slope = (x2 - x1) / (y2 - y1);
        
        while y ~= y2
            y = y + yStep;
            x = x1 + slope * (y - y1);
            newX = round(x);
            
            % Check if new point shares a side with previous point
            if ~(newX == prevX || y == prevY)
                % Add intermediate point (Ax = Q2x, Ay = Q1y)
                mask(newX, prevY) = 1;
            end
            
            % Set current point
            if newX >= 1 && newX <= imageSize(1) && y >= 1 && y <= imageSize(2)
                mask(newX, y) = 1;
            end
            
            % Update previous point
            prevX = newX;
            prevY = y;
        end
    end
    
    mask = logical(mask);
end

function [perpVector] = calculatePerpendicularVector(startPoint, endPoint, width)
    % Calculate the direction vector of the line
    direction = endPoint - startPoint;

    % Normalize the direction vector
    normDirection = direction / norm(direction);

    % Calculate the perpendicular vector
    perpVector = [-normDirection(2), normDirection(1)] * (width / 2);  
end

function [perpendicularStart, perpendicularEnd] = calculatePerpendicularLinePoints(perpVector, point)
    % Calculate the two endpoints of the perpendicular line
    perpendicularStart = round(point + perpVector);  % Start point of the perpendicular line
    perpendicularEnd = round(point - perpVector);    % End point of the perpendicular line
end

function [figMasks] = plotMasks(masks,startPoint,endPoint) 
    % Print combination summary
    fprintf('\nMask Generation Summary:\n');
    fprintf('Original masks: %d x %d x %d\n', size(masks));
    % Create figure for combined results visualization
    figMasks = figure('Name', 'Masks_stack Result');
    % Original masks sum
    imagesc(permute(sum(masks,3), [2,1]));
    hold on
    % Plot the main line if available
    if ~isempty(startPoint) && ~isempty(endPoint)
        line([startPoint(1), endPoint(1)], ...
             [startPoint(2), endPoint(2)], ...
             'Color', 'b', 'LineWidth', 3);
    end
    setGraphLayout("2D_Image");
    %overwrite titel string: 
    ax = gca;
    ax.Title.String = "Sum of Original Masks";
end

%% combineMasks() helper functions

function [figMasks] = plotCombineMasks(masks,masks_combined,startPoint,endPoint,bin_size, bin_sep) 
    % Print combination summary
    fprintf('\nMask Generation Summary:\n');
    fprintf('Original masks: %d x %d x %d\n', size(masks));
    fprintf('Combined masks: %d x %d x %d\n', size(masks_combined));
    fprintf('Binning: size=%d, separation=%d\n', bin_size, bin_sep);
    if bin_sep < bin_size
        fprintf('Overlap: %d slices\n', bin_size - bin_sep);
    elseif bin_sep > bin_size
        fprintf('Gap: %d slices\n', bin_sep - bin_size);
    end
    
    % Create figure for combined results visualization
    figMasks = figure('Name', 'Combined Masks Result');
    
    % Original masks sum
    subplot(1,2,1);
    imagesc(permute(sum(masks,3), [2,1]));
    hold on
    % Plot the main line if available
    if ~isempty(startPoint) && ~isempty(endPoint)
        line([startPoint(1), endPoint(1)], ...
             [startPoint(2), endPoint(2)], ...
             'Color', 'b', 'LineWidth', 3);
    end
    setGraphLayout("2D_Image");
    %overwrite titel string: 
    ax = gca;
    ax.Title.String = 'Sum of Original Masks';
    
    % Combined masks sum
    subplot(1,2,2);
    imagesc(permute(sum(masks_combined,3), [2,1]));
    hold on
    % Plot the main line if available
    if ~isempty(startPoint) && ~isempty(endPoint)
        line([startPoint(1), endPoint(1)], ...
             [startPoint(2), endPoint(2)], ...
             'Color', 'b', 'LineWidth', 3);
    end
    setGraphLayout("2D_Image");
    %overwrite titel string: 
    ax = gca;
    ax.Title.String = sprintf('Sum of Combined Masks\n(bin\\_size=%d, bin\\_sep=%d)', ...
    bin_size,bin_sep);
end

