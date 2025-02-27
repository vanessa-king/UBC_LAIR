function [masks, masks_combined, comment] = maskDirectional(data, varargin)
% MASKDIRECTIONAL Create directional masks and combine them
% This function is a wrapper that creates directional masks and optionally
% combines them using specified binning parameters.
%
% Arguments:
%   data            2D or 3D array containing the data
%   varargin        Optional arguments:
%                   - connected: logical flag for side connectivity (default false)
%                   - startPoint: [x1,y1] start point coordinates
%                   - endPoint: [x2,y2] end point coordinates
%                   - bin_size: Number of slices to combine per bin
%                   - bin_sep: Separation between start of each bin
%
% Returns:
%   masks           3D array of original masks (data_dim x data_dim x L)
%   masks_combined  3D array of combined masks (if bin parameters provided)
%                   or empty array (if no bin parameters)
%   comment         String containing function call information
%
% Example:
%   % Just create masks:
%   [masks, ~, comment] = maskDirectional(data)
%   % Create and combine masks:
%   [masks, masks_combined, comment] = maskDirectional(data, 'bin_size', 3, 'bin_sep', 2)
%

% Dec 2024 - Dong Chen

% Check if input is 3D
if ndims(data) == 3
    % Display 3D dataset
    fprintf('3D dataset detected. Please select a slice for mask creation.\n');
    gridSliceViewer(data, 1,'dynamic');
    
    % Prompt user for slice selection
    slice_idx = input('Enter the slice number to use: ');
    while isempty(slice_idx) || slice_idx < 1 || slice_idx > size(data, 3)
        fprintf('Invalid slice number. Please enter a number between 1 and %d\n', size(data, 3));
        slice_idx = input('Enter the slice number to use: ');
    end
    
    % Extract the selected slice
    data = data(:,:,slice_idx);
    fprintf('Using slice %d for mask creation\n', slice_idx);
end

% Parse optional inputs
p = inputParser;
addParameter(p, 'connected', false, @islogical);
addParameter(p, 'startPoint', [], @(x) isempty(x) || (isnumeric(x) && numel(x)==2));
addParameter(p, 'endPoint', [], @(x) isempty(x) || (isnumeric(x) && numel(x)==2));
addParameter(p, 'bin_size', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x > 0));
addParameter(p, 'bin_sep', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x > 0));
parse(p, varargin{:});

% Get directional masks
[masks, dir_comment] = maskSingleDirectional(data, p.Results.connected, ...
    p.Results.startPoint, p.Results.endPoint);

% Initialize combined masks as empty
masks_combined = [];
comment = dir_comment;

% Only combine masks if both bin parameters are provided
if ~isempty(p.Results.bin_size) && ~isempty(p.Results.bin_sep)
    [masks_combined, idx] = combineMasks(masks, p.Results.bin_size, p.Results.bin_sep);
    
    % Update comment
    comment = sprintf('%s\nCombined with bin_size=%d, bin_sep=%d', ...
        dir_comment, p.Results.bin_size, p.Results.bin_sep);
    
    % Print combination summary
    fprintf('\nMask Generation Summary:\n');
    fprintf('Original masks: %d x %d x %d\n', size(masks));
    fprintf('Combined masks: %d x %d x %d\n', size(masks_combined));
    fprintf('Binning: size=%d, separation=%d\n', p.Results.bin_size, p.Results.bin_sep);
    if p.Results.bin_sep < p.Results.bin_size
        fprintf('Overlap: %d slices\n', p.Results.bin_size - p.Results.bin_sep);
    elseif p.Results.bin_sep > p.Results.bin_size
        fprintf('Gap: %d slices\n', p.Results.bin_sep - p.Results.bin_size);
    end
    
    % Create figure for combined results visualization
    figure('Name', 'Combined Masks Result');
    
    % Original masks sum
    subplot(1,2,1);
    imagesc(permute(sum(masks,3), [2,1]));
    hold on
    % Plot the main line if available
    if ~isempty(p.Results.startPoint) && ~isempty(p.Results.endPoint)
        line([p.Results.startPoint(1), p.Results.endPoint(1)], ...
             [p.Results.startPoint(2), p.Results.endPoint(2)], ...
             'Color', 'red', 'LineWidth', 1.5);
    end
    axis xy
    axis equal
    colorbar;
    title('Sum of Original Masks');
    
    % Combined masks sum
    subplot(1,2,2);
    imagesc(permute(sum(masks_combined,3), [2,1]));
    hold on
    % Plot the main line if available
    if ~isempty(p.Results.startPoint) && ~isempty(p.Results.endPoint)
        line([p.Results.startPoint(1), p.Results.endPoint(1)], ...
             [p.Results.startPoint(2), p.Results.endPoint(2)], ...
             'Color', 'red', 'LineWidth', 1.5);
    end
    axis xy
    axis equal
    colorbar;
    title(sprintf('Sum of Combined Masks\n(bin\\_size=%d, bin\\_sep=%d)', ...
        p.Results.bin_size, p.Results.bin_sep));
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

function [masks, comment] = maskSingleDirectional(data, connected, startPoint, endPoint)
%Average grid along a given direction with interactive width selection
% Arguments:
%   data        2D or 3D array containing the data.
%   connected   logical flag for side connectivity (optional, default false)
%   startPoint  [x1,y1] start point coordinates (optional)
%   endPoint    [x2,y2] end point coordinates (optional)
%
% Returns:
%   masks       3D array of logical masks (data_dim x data_dim x L)
%   comment     Comment for logging the function call.
% Dec 2024 - Dong Chen

arguments
    data
    connected logical = false
    startPoint {mustBeNumeric, mustBePositive} = []
    endPoint {mustBeNumeric, mustBePositive} = []
end

% Declare global state
global UI_STATE

% Initialize state structure
UI_STATE = struct();
UI_STATE.width = 10;
UI_STATE.isDragging = false;
UI_STATE.rectHandle = [];
UI_STATE.dragHandles = [];
UI_STATE.widthField = [];

% Get main line and initialize vectors
[mainMask, mainComment, UI_STATE.startPoint, UI_STATE.endPoint, polcoord] = ...
    gridMaskLineSegment(data, startPoint, endPoint, [], connected);

if isempty(UI_STATE.startPoint) || isempty(UI_STATE.endPoint)
    error('Line selection was cancelled or invalid');
end

% Calculate and store main vectors
UI_STATE.lineVector = UI_STATE.endPoint - UI_STATE.startPoint;
UI_STATE.perpVector = [-UI_STATE.lineVector(2), UI_STATE.lineVector(1)];
UI_STATE.perpVector = UI_STATE.perpVector / norm(UI_STATE.perpVector);

% Create UI for width selection
createWidthSelectionUI(data);

% Wait for user confirmation
uiwait(gcf);

% Generate masks using global state
masks = generatePerpMasks(data, mainMask);

% Visualize final sum of masks
figure('Name', 'Final Directional Mask Result');
imagesc(permute(sum(masks,3), [2,1]));
hold on
% Plot the main line
line([UI_STATE.startPoint(1), UI_STATE.endPoint(1)], ...
     [UI_STATE.startPoint(2), UI_STATE.endPoint(2)], ...
     'Color', 'red', 'LineWidth', 1.5);
axis xy
axis equal
colorbar;
title(sprintf('Sum of All Perpendicular Masks (width=%d)', UI_STATE.width));

% Create comment for logging
comment = sprintf('maskSingleDirectional(datasize:%s x %s, width:%d)|%s', ...
    mat2str(size(data,1)), mat2str(size(data,2)), UI_STATE.width, mainComment);

% Clear global state
clear global UI_STATE
end

%% Helper functions

function createWidthSelectionUI(data)
    global UI_STATE
    
    % Create figure
    figure('WindowButtonMotionFcn', @updateRectangle);
    imagesc(permute(data, [2,1,3]));
    axis xy
    axis equal
    hold on
    
    % Draw original line
    line([UI_STATE.startPoint(1), UI_STATE.endPoint(1)], ...
         [UI_STATE.startPoint(2), UI_STATE.endPoint(2)], ...
         'Color', 'red', 'LineWidth', 1.5);
    
    % Add width display/edit field
    widthField = uicontrol('Style', 'edit', ...
        'String', num2str(UI_STATE.width), ...
        'Position', [10 50 100 30], ...
        'Callback', @updateWidthFromText);
    
    % Update state with widthField handle
    UI_STATE.widthField = widthField;
    
    % Add width label
    uicontrol('Style', 'text', ...
        'String', 'Width:', ...
        'Position', [10 80 100 20], ...
        'BackgroundColor', get(gcf, 'Color'));
    
    % Add confirm button
    uicontrol('Style', 'pushbutton', ...
        'String', 'Confirm Width', ...
        'Position', [10 10 100 30], ...
        'Callback', @confirmWidth);
    
    % Set figure callbacks for dragging
    set(gcf, 'WindowButtonDownFcn', @startDragging);
    set(gcf, 'WindowButtonUpFcn', @stopDragging);
    set(gcf, 'WindowButtonMotionFcn', @updateDragging);
    
    % Initial visualization
    updateRectangle();
    createDragHandles();
    
    % Modify all nested functions to use global UI_STATE instead of state
    function updateWidthFromText(src, ~)
        newWidth = round(str2double(get(src, 'String')));
        
        % Basic validation
        if isnan(newWidth) || newWidth <= 0
            set(src, 'String', num2str(UI_STATE.width));
            return;
        end
        
        % Check if new width would exceed bounds
        perpVector_scaled = UI_STATE.perpVector * newWidth/2;
        corners = [
            UI_STATE.startPoint + perpVector_scaled;
            UI_STATE.endPoint + perpVector_scaled;
            UI_STATE.endPoint - perpVector_scaled;
            UI_STATE.startPoint - perpVector_scaled
        ];
        
        % Check if any corner would be out of bounds
        data_size = size(data);
        for i = 1:size(corners,1)
            if any(corners(i,:) < 1) || ...
               corners(i,1) > data_size(1) || ...
               corners(i,2) > data_size(2)
                % Revert to previous width if new width would exceed bounds
                set(src, 'String', num2str(UI_STATE.width));
                return;
            end
        end
        
        % If we get here, the new width is valid
        UI_STATE.width = newWidth;
        updateRectangle();
        createDragHandles();
    end
    
    function startDragging(src, ~)
        if strcmp(get(src, 'Tag'), 'dragHandle')
            UI_STATE.isDragging = true;
            set(gcf, 'Pointer', 'fleur');
        end
    end
    
    function stopDragging(~, ~)
        UI_STATE.isDragging = false;
        set(gcf, 'Pointer', 'arrow');
    end
    
    function confirmWidth(~, ~)
        fprintf('Final width confirmed: %d\n', UI_STATE.width);
        fprintf('Line vector: [%.2f, %.2f]\n', UI_STATE.lineVector(1), UI_STATE.lineVector(2));
        fprintf('Perpendicular vector: [%.2f, %.2f]\n', UI_STATE.perpVector(1), UI_STATE.perpVector(2));
        uiresume(gcf);
        close(gcf);
    end
    
    function updateDragging(~, ~)
        if UI_STATE.isDragging
            % Get current point in axis coordinates
            currentPos = get(gca, 'CurrentPoint');
            mousePoint = [currentPos(1,1), currentPos(1,2)];
            
            % Calculate new width as twice the distance from point to line
            newWidth = round(2 * pointToLineDistance(mousePoint));
            
            % Calculate potential corner positions with new width
            perpVector_scaled = UI_STATE.perpVector * newWidth/2;
            corners = [
                UI_STATE.startPoint + perpVector_scaled;
                UI_STATE.endPoint + perpVector_scaled;
                UI_STATE.endPoint - perpVector_scaled;
                UI_STATE.startPoint - perpVector_scaled
            ];
            
            % Check if any corner would be out of bounds
            data_size = size(data);
            for i = 1:size(corners,1)
                if any(corners(i,:) < 1) || ...
                   corners(i,1) > data_size(1) || ...
                   corners(i,2) > data_size(2)
                    % Skip update if any corner would be outside data bounds
                    return;
                end
            end
            
            % If we get here, the new width is valid
            UI_STATE.width = newWidth;
            set(UI_STATE.widthField, 'String', num2str(UI_STATE.width));
            updateRectangle();
            createDragHandles();
        end
    end
    
    function distance = pointToLineDistance(point)
        lineVector = UI_STATE.lineVector;
        pointVector = point - UI_STATE.startPoint;
        
        % Calculate perpendicular distance using cross product
        distance = abs(lineVector(1)*pointVector(2) - lineVector(2)*pointVector(1)) / ...
            norm(lineVector);
    end
    
    function updateRectangle()
        % Use the already calculated perpVector scaled by width/2
        perpVector_scaled = UI_STATE.perpVector * UI_STATE.width/2;
        
        corners = [
            UI_STATE.startPoint + perpVector_scaled;
            UI_STATE.endPoint + perpVector_scaled;
            UI_STATE.endPoint - perpVector_scaled;
            UI_STATE.startPoint - perpVector_scaled;
            UI_STATE.startPoint + perpVector_scaled  % Close the rectangle
            ];
        
        % Update rectangle
        delete(UI_STATE.rectHandle);
        if ~isempty(UI_STATE.dragHandles)
            delete(UI_STATE.dragHandles);
        end
        
        UI_STATE.rectHandle = line(corners(:,1), corners(:,2), ...
            'Color', 'blue', 'LineStyle', '--');
    end
    
    function createDragHandles()
        % Calculate handle positions using perpVector
        perpVector_scaled = UI_STATE.perpVector * UI_STATE.width/2;
        
        % Create drag handles on both sides of the line
        UI_STATE.dragHandles = [
            plot(UI_STATE.startPoint(1) + perpVector_scaled(1), ...
                 UI_STATE.startPoint(2) + perpVector_scaled(2), 'bs', ...
                 'MarkerFaceColor', 'b', 'MarkerSize', 8, 'Tag', 'dragHandle'),
            plot(UI_STATE.startPoint(1) - perpVector_scaled(1), ...
                 UI_STATE.startPoint(2) - perpVector_scaled(2), 'bs', ...
                 'MarkerFaceColor', 'b', 'MarkerSize', 8, 'Tag', 'dragHandle')
        ];
        
        % Make handles draggable
        set(UI_STATE.dragHandles, 'ButtonDownFcn', @startDragging);
    end
end

function masks = generatePerpMasks(data, mainMask)
    global UI_STATE
    % Find all points along the main line
    [linePoints_x, linePoints_y] = find(mainMask);
    linePoints = [linePoints_x, linePoints_y];
    lineLength = length(linePoints_x);
    fprintf('Number of points along main line: %d\n\n', lineLength);
    
    % Initialize 3D mask array
    masks = false(size(data,1), size(data,2), lineLength);
    
    % Calculate perpendicular vector scaled by width/2
    perpVector_scaled = UI_STATE.perpVector * UI_STATE.width/2;
    
    % Generate perpendicular line masks
    for i = 1:lineLength
        midPoint = linePoints(i,:);
        
        % Calculate perpendicular start and end points
        perpStart = round(midPoint - perpVector_scaled);
        perpEnd = round(midPoint + perpVector_scaled);
        % print the points
        % Check bounds
        if all(perpStart > 0) && all(perpEnd > 0) && ...
           all(perpStart <= size(data)) && all(perpEnd <= size(data))
            perpMask = gridMaskLineSegment(data, perpStart, perpEnd, []);
            masks(:,:,i) = perpMask;
        else
            warning('Skipping mask at point %d due to bounds', i);
        end
    end
end

function [mask] = createLineSegmentMask_connected(imageSize, startPoint, endPoint)
    mask = zeros(imageSize);
    
    % Round points to nearest integer
    x1 = round(startPoint(1));
    y1 = round(startPoint(2));
    x2 = round(endPoint(1));
    y2 = round(endPoint(2));
    
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
