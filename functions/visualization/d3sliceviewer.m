function [data2D, mask, comment] = d3sliceviewer(data3D, mode, contrast, mask)
% D3SLICEVIEWER Creates a 2D slice viewer from 3D data with line/segment selection
%   This function allows users to select points on a slice of 3D data and create
%   a line or line segment mask based on those points.
%
% Inputs:
%   data3D - 3D dataset to visualize
%   mode   - 'segment' or 'line' to determine mask type
%   contrast - 'dynamic' or 'global' for data normalization (default: 'dynamic')
%   mask   - (Optional) 3D mask array. If provided, skips point selection
%
% Outputs:
%   data2D - 2D array of values along the line across slices
%   mask   - 3D mask array (1 for selected points, NaN for others)
%   comment - Log comment string
%
% Example:
%   [data2D, mask, comment] = d3sliceviewer(LDoS_noisy, 'segment', 'dynamic', [])
%
% Created: March 2024

% Validate inputs
arguments
    data3D {mustBeNumeric}
    mode {mustBeMember(mode, {'segment', 'line'})}
    contrast {mustBeMember(contrast, {'dynamic', 'global'})} = 'dynamic'
    mask {mustBeNumeric} = []
end

% If mask is provided, skip point selection
if ~isempty(mask)
    % Validate mask dimensions
    if ~isequal(size(mask), size(data3D))
        error('Provided mask must have same dimensions as data3D');
    end
    
    % Get the coordinates of masked points in the first slice
    [y_coords, x_coords] = find(~isnan(mask(:,:,1)));
    
    % Create the 2D data array
    data2D = zeros(length(x_coords), size(data3D, 3));
    for i = 1:size(data3D, 3)
        for j = 1:length(x_coords)
            data2D(j, i) = data3D(y_coords(j), x_coords(j), i);
        end
    end
    
    % Apply contrast normalization
    switch contrast
        case 'dynamic'
            % Normalize each slice independently
            for i = 1:size(data2D, 2)
                slice_data = data2D(:,i);
                data2D(:,i) = (slice_data - min(slice_data)) / (max(slice_data) - min(slice_data));
            end
        case 'global'
            % No normalization needed for global contrast
    end
    
    % Plot the data with flipped axes
    figure;
    imagesc(data2D');
    colormap gray;
    xlabel('Position along line');
    ylabel('Slice number');
    title('Line values across slices');
    colorbar;
    
    comment = sprintf("d3sliceviewer(data:%s x %s x %s, mode: %s, contrast: %s)| Using provided mask", ...
        mat2str(size(data3D,1)), mat2str(size(data3D,2)), mat2str(size(data3D,3)), mode, contrast);
    return;
end

% Step 1: Display 3D data and select slice
figure;
d3gridDisplay(data3D, 'dynamic');
title('Select a slice to draw points on');

% Get slice selection from user
slice_idx = input('Enter slice number to draw points on: ');
if isempty(slice_idx) || slice_idx < 1 || slice_idx > size(data3D, 3)
    error('Invalid slice number');
end
close;

% Display selected slice
fig = figure;
imagesc(data3D(:,:,slice_idx));
colormap gray;
axis equal;
title(sprintf('Slice %d - Select points', slice_idx));

% Step 2: Select point selection mode
disp('Select point selection mode:');
disp('1. Through the center');
disp('2. Through Braggs');
disp('3. Other');
mode_choice = input('Enter mode number (1-3): ');

switch mode_choice
    case 1 % Through the center
        [pointA, pointB] = selectPointsThroughCenter(data3D(:,:,slice_idx), mode, fig);
    case 2 % Through Braggs
        [pointA, pointB] = selectPointsThroughBraggs(data3D(:,:,slice_idx), fig);
    case 3 % Other
        [mask,~,pointA, pointB, ~] = gridMaskLineSegment(data3D(:,:,slice_idx));
    otherwise
        error('Invalid mode selection');
end

% Generate mask based on pointA and pointB
switch mode
    case 'segment'
        mask = gridMaskLineSegment(data3D(:,:,slice_idx), pointA, pointB);
    case 'line'
        mask = gridMaskLine(data3D(:,:,slice_idx), pointA, pointB);
end

comment = sprintf("d3sliceviewer(data:%s x %s x %s, mode: %s, contrast: %s)| line defined by pt1: %s, pt2: %s", ...
    mat2str(size(data3D,1)), mat2str(size(data3D,2)), mat2str(size(data3D,3)), mode, contrast, pointA, pointB);

% Convert mask to double and set zeros to NaN
mask = double(mask);
mask(mask == 0) = NaN;

% extend mask to 3D
mask = repmat(mask, [1, 1, size(data3D, 3)]);

% Get the coordinates of masked points in the first slice
[y_coords, x_coords] = find(~isnan(mask(:,:,1)));

% Calculate distances along the line for x-axis
switch mode
    case 'segment'
        % For segment mode, calculate actual distances
        distances = sqrt((x_coords - pointA(2)).^2 + (y_coords - pointA(1)).^2);
        [~, sort_idx] = sort(distances);
        x_coords = x_coords(sort_idx);
        y_coords = y_coords(sort_idx);
    case 'line'
        % For line mode, use projection onto line
        line_vec = [pointB(2) - pointA(2), pointB(1) - pointA(1)];
        line_vec = line_vec / norm(line_vec);
        points = [x_coords - pointA(2), y_coords - pointA(1)];
        distances = points * line_vec';
        [~, sort_idx] = sort(distances);
        x_coords = x_coords(sort_idx);
        y_coords = y_coords(sort_idx);
end

% Create the 2D data array
data2D = zeros(length(x_coords), size(data3D, 3));
for i = 1:size(data3D, 3)
    for j = 1:length(x_coords)
        data2D(j, i) = data3D(y_coords(j), x_coords(j), i);
    end
end

% Apply contrast normalization
switch contrast
    case 'dynamic'
        % Normalize each slice independently
        for i = 1:size(data2D, 2)
            slice_data = data2D(:,i);
            data2D(:,i) = (slice_data - min(slice_data)) / (max(slice_data) - min(slice_data));
        end
    case 'global'
        % No normalization needed for global contrast
end

% Plot the data with flipped axes
figure;
imagesc(data2D');
colormap gray;
xlabel('Position along line');
ylabel('Slice number');
title('Line values across slices');
colorbar;

function [pointA, pointB] = selectPointsThroughCenter(slice, mode, fig)
% Select points through the center of the slice
[rows, cols] = size(slice);
center = [floor(rows/2)+1, floor(cols/2)+1];

% Display center point
hold on;
plot(center(2), center(1), 'r+', 'MarkerSize', 10);

% Get initial point from user click
disp('Click a point to start the segment');
initial_point = ginput(1);
initial_point = round(initial_point);
initial_opposite_point = [center(2) - (initial_point(1) - center(2)), center(1) - (initial_point(2) - center(1))];

% Create initial line
h_line = line([initial_point(1), initial_opposite_point(1)], [initial_point(2), initial_opposite_point(2)], 'Color', 'r', 'LineWidth', 2);

% Create draggable point for rotation
h_point = plot(initial_point(1), initial_point(2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');

% Initialize points in figure data
setappdata(fig, 'pointA', [initial_point(2), initial_point(1)]);
setappdata(fig, 'pointB', [initial_opposite_point(2), initial_opposite_point(1)]);
setappdata(fig, 'isDragging', false);

% Set up callback for dragging
set(h_point, 'ButtonDownFcn', @startDragFcn);

% Wait for user to finish rotating
disp('Click and drag the red point to rotate. Press *Enter* to finish.');
key = waitforbuttonpress;
while ~key || get(fig, 'CurrentCharacter') ~= char(13)
    key = waitforbuttonpress;
end

% Get final points from figure data
pointA = getappdata(fig, 'pointA');
pointB = getappdata(fig, 'pointB');

% Clean up
if ishandle(h_line)
    delete(h_line);
end
if ishandle(h_point)
    delete(h_point);
end
hold off;

    function startDragFcn(src, ~)
        % Get the figure handle
        fig = ancestor(src, 'figure');
        
        % Set dragging flag
        setappdata(fig, 'isDragging', true);
        
        % Set up callbacks
        set(fig, 'WindowButtonMotionFcn', @dragFcn);
        set(fig, 'WindowButtonUpFcn', @stopDragFcn);
        
        function dragFcn(~, ~)
            try
                % Check if objects are still valid
                if ~ishandle(h_point) || ~ishandle(h_line)
                    stopDragFcn([], []);
                    return;
                end
                
                % Get current point
                pt = get(gca, 'CurrentPoint');
                pt = pt(1, 1:2);
                pt = round(pt);
                
                % Calculate opposite point
                opposite_pt = [center(2) - (pt(1) - center(2)), center(1) - (pt(2) - center(1))];
                
                % Update point and line positions
                set(h_point, 'XData', pt(1), 'YData', pt(2));
                set(h_line, 'XData', [pt(1), opposite_pt(1)], 'YData', [pt(2), opposite_pt(2)]);
                
                % Update points in figure data
                setappdata(fig, 'pointA', [pt(2), pt(1)]);
                setappdata(fig, 'pointB', [opposite_pt(2), opposite_pt(1)]);
                
                % Force draw update
                drawnow;
            catch
                % If any error occurs, stop the drag operation
                stopDragFcn([], []);
            end
        end
        
        function stopDragFcn(~, ~)
            try
                % Get the figure handle
                fig = ancestor(src, 'figure');
                
                % Set dragging flag
                setappdata(fig, 'isDragging', false);
                
                % Remove callbacks
                if ishandle(fig)
                    set(fig, 'WindowButtonMotionFcn', '');
                    set(fig, 'WindowButtonUpFcn', '');
                end
            catch
                % If any error occurs, just continue
            end
        end
    end
end

function [pointA, pointB] = selectPointsThroughBraggs(slice, fig)
% Select points through Bragg peaks
disp('Draw a circle around first Bragg peak');
h = drawcircle;
wait(h);
pointA = findMaxInCircle(slice, h.Center, h.Radius);
delete(h);

disp('Draw a circle around second Bragg peak');
h = drawcircle;
wait(h);
pointB = findMaxInCircle(slice, h.Center, h.Radius);
delete(h);

% Draw line between points and label them
hold on;
drawLineAB(pointA, pointB);
text(pointA(2), pointA(1), 'A', 'Color', 'y', 'FontWeight', 'bold');
text(pointB(2), pointB(1), 'B', 'Color', 'y', 'FontWeight', 'bold');
hold off;
end

function drawLineAB(pointA, pointB)
% Utility function to draw a line between two points
line([pointA(2), pointB(2)], [pointA(1), pointB(1)], 'Color', 'r', 'LineWidth', 2);
end

function maxPoint = findMaxInCircle(slice, center, radius)
% Find point with maximum intensity within a circle
[rows, cols] = size(slice);
[X, Y] = meshgrid(1:cols, 1:rows);
distances = sqrt((X - center(1)).^2 + (Y - center(2)).^2);
mask = distances <= radius;
[~, idx] = max(slice(mask));
[y, x] = find(mask);
maxPoint = [y(idx), x(idx)];
end

function mustBe3D(x)
% Validate that input is 3D
if ndims(x) ~= 3
    error('Input must be a 3D array');
end

end

end