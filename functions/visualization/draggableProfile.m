function [fig, comment] = draggableProfile(data, n, V_reduced, imageV, startPoint, endPoint, width)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    data        
    n           {mustBePositive}    =[]     % optional, only for 3D data
    V_reduced   {mustBeNumeric}     =[]     % optional, only for 3D data
    imageV      {mustBeNumeric}     =[]     % optional, only for 3D data 
    startPoint  {mustBeNumeric}     =[]     % optional, to reproduce ROI
    endPoint    {mustBeNumeric}     =[]     % optional, to reproduce ROI
    width       {mustBeNumeric}     =[]     % optional, to reproduce ROI    
end

arguments (Output)
    fig
    comment
end

% ensure 2D image 
[data_slice, imN, V_actual] = dataSlice2D(data,n,V_reduced,imageV);

% draw and move ROI on image -> confirm to continue / reproduce ROI 
[startPoint, endPoint, width, fig] = drawROIlineWidthAndPlot(data_slice,startPoint, endPoint, width); 

% comment:display ROI selection for LOG
comment = sprintf("draggableProfile() executed, GUI selection: startPoint = %s, endPoint = %s, width = %s;", mat2str(startPoint),mat2str(endPoint),mat2str(width));
end

%% main helper functions

function [ROIstartPoint, ROIendPoint, ROIwidth, f] = drawROIlineWidthAndPlot(data_slice, startPoint, endPoint, width)

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
    f = figure('Name','Select profile by dragging the ROI');
    subplot(1,2,1)
    imagesc(permute(data_slice,[2 1]));
    axA = gca;
    setGraphLayout("2D_Image");
    %overwrite titel string: 
    axA.Title.String = "Line selection - confirm with ENTER";
    hold on

    subplot(1,2,2)
    setGraphLayout("topoProfile");

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
        [mainLineROI, widthLineA, ~] = drawShadedROI(f, axA,startPoint, endPoint, width,szLimits, byPassBool, data_slice);
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

function [avg,std] = calculateMaskedAverage(data_slice, startPoint, endPoint, width)
    % calc size
    sz = size(data_slice);
    
    %round all inputs
    startPoint = round(startPoint);
    endPoint = round(endPoint);
    width = round(width);

    % make main line as a mainLineMask
    mainLineMask = createLineSegmentMask(sz, startPoint, endPoint);

    % use loop over find(mainLineMask) to make perp masks of width  
    % Find all points along the main line and assing their [x y] coordinates to mainLinePoints
    [mainLineMask_x, mainLineMask_y] = find(mainLineMask);
    mainLinePoints =  [mainLineMask_x, mainLineMask_y];
    mainLineLength = length(mainLineMask_x);
    % calculate perpendicular vector for small mask endpoints & initialize
    % maskStack with correct dimensions
    [perpVector] = calculatePerpendicularVector(startPoint, endPoint, width);
    avg = zeros(mainLineLength,1);
    std = zeros(mainLineLength,1);
    %loop over each point and make the submask
    for n = 1:mainLineLength
        [perpendicularStart, perpendicularEnd] = calculatePerpendicularLinePoints(perpVector, mainLinePoints(n,:));
        mask = createLineSegmentMask(sz, perpendicularStart, perpendicularEnd);
        [~, avg(n), std(n), ~] = avgXYmask(data_slice, mask, 1);
    end

end

%% drawROIlineWidth() helper functions

function [lineROI] = drawLineROI(ax,startPoint, endPoint, color)
    lineROI = images.roi.Line(ax,'Position', [startPoint; endPoint], ...
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

function [mainLineROI, widthLineA, widthLineB] = drawShadedROI(f, ax, startPoint, endPoint, width, szLimits, bypassBool, data_slice)
    % Calculate the corners of the shaded area
    corners = calculateShadedCorners(startPoint, endPoint, width);
    % Draw the shaded area
    shadedArea = images.roi.Polygon(ax,'Position',corners,'Color','r','FaceAlpha', 0.2, 'LineWidth',1,'InteractionsAllowed','none');
    % draw width marker lines
    widthLineA = drawLineROI(ax,corners(1,:), corners(2,:),'r');
    widthLineB = drawLineROI(ax,corners(3,:), corners(4,:),'r');
    % Draw main line on top
    hold on
    mainLineROI = drawLineROI(ax,startPoint, endPoint,'b');
    % Draw initial profile 
    [mainLineROI, widthLineA, widthLineB, shadedArea] = onROIMoved(mainLineROI, [], f, widthLineA,widthLineB, shadedArea, data_slice);
    
    % reproduce data case 
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

    addlistener(widthLineA, 'ROIMoved', @(src, event) onROIMoved(mainLineROI, event, f, widthLineA,widthLineB, shadedArea, data_slice));
    addlistener(widthLineB, 'ROIMoved', @(src, event) onROIMoved(mainLineROI, event, f, widthLineA,widthLineB, shadedArea, data_slice));
    addlistener(mainLineROI, 'ROIMoved', @(src, event) onROIMoved(mainLineROI, event, f, widthLineA,widthLineB, shadedArea, data_slice));

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

%% drawShadedROI - ROImoved redraw the profile

function [mainLineROI, widthLineA, widthLineB, shadedArea] = onROIMoved(mainLineROI, event, f, widthLineA,widthLineB, shadedArea, data_slice)
    

    [avg,std] = calculateMaskedAverage(data_slice, mainLineROI.Position(1,:), mainLineROI.Position(2,:), norm(widthLineA.Position(2,:)-widthLineA.Position(1,:)));

    set(0, 'CurrentFigure', f);
    subplot(1,2,2,'replace');
    xCor = 1:length(avg);
    pPlot = plot(xCor,avg,"LineWidth",1.5,'DisplayName', 'Average line profile');
    setGraphLayout("topoProfile");
    hold on
    xCoords = [xCor'; flipud(xCor')];
    yCoords = [avg + std; flipud(avg - std)];   
    % Fill the area with the same color as the plot
    fill(xCoords, yCoords, 'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none','DisplayName', 'Standard deviation of line profile');  % Empty DisplayName to exclude from legend   
    legend('Location','southeast');
    hold off
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
