function [data2D, angles] = rotational_slices(data3D, rangetype, line_width)
% ROTATIONAL_SLICES Creates 2D slices from 3D data by rotating a line through the center
%   This function creates a series of 2D slices by rotating a line through the center
%   of the data at different angles. The user adjusts a pre-drawn circle to determine the line length.
%
% Inputs:
%   data3D - 3D dataset to visualize
%   rangetype - 'dynamic' or 'global' for data normalization
%   line_width - Width of the line in pixels (default: 1)
%
% Outputs:
%   data2D - 3D array where:
%            dim1: position along the line
%            dim2: original data slices (energy)
%            dim3: angle slices
%   angles - Array of angles used for rotation (in radians)
%
% Example:
%   [data2D, angles] = rotational_slices(LDoS_noisy, 'dynamic', 3)
%
% Created: March 2024

% Validate inputs
arguments
    data3D {mustBeNumeric}
    rangetype {mustBeMember(rangetype, {'dynamic', 'global'})} = 'dynamic'
    line_width {mustBeInteger, mustBePositive} = 1
end

% Calculate center point
[rows, cols, ~] = size(data3D);
center = [floor(rows/2)+1, floor(cols/2)+1];

% Display the first slice
figure;
imagesc(data3D(:,:,floor(size(data3D,3))/2));
colormap gray;
axis equal;
title('Adjust circle radius to determine line length');
hold on;

% Create initial circle with radius 1
h = drawcircle('Center', [center(2), center(1)], 'Radius', 1);
h.FaceAlpha = 0.1;  % Make circle semi-transparent

% Wait for user to finish adjusting
wait(h);

% Get circle properties
radius = h.Radius;

% Clean up
delete(h);
hold off;

% Generate angles (0 to pi)
angles = linspace(0, pi, 360);

% Calculate maximum possible points for any angle
% This will be the diameter of the circle in pixels
max_points = 2 * round(radius);

% Pre-allocate output array with correct dimensions
data2D = zeros(max_points, size(data3D, 3), length(angles));

% Process each angle
for i = 1:length(angles)
    % Calculate endpoints on circle
    theta = angles(i);
    pointA = round([center(1) + radius*cos(theta), center(2) + radius*sin(theta)]);
    pointB = round([center(1) - radius*cos(theta), center(2) - radius*sin(theta)]);
    
    % Ensure points are within bounds
    pointA = max(1, min([rows, cols], pointA));
    pointB = max(1, min([rows, cols], pointB));
    
    % Calculate perpendicular direction for line width
    line_vec = [pointB(2) - pointA(2), pointB(1) - pointA(1)];
    line_vec = line_vec / norm(line_vec);
    perp_vec = [-line_vec(2), line_vec(1)];  % Rotate 90 degrees
    
    % Initialize array for width-averaged data
    width_data = zeros(max_points, size(data3D, 3), line_width);
    
    % Process each parallel line
    for w = 1:line_width
        % Calculate offset for this line
        offset = (w - (line_width+1)/2) * perp_vec;
        
        % Calculate offset points
        pointA_offset = round(pointA + offset);
        pointB_offset = round(pointB + offset);
        
        % Ensure points are within bounds
        pointA_offset = max(1, min([rows, cols], pointA_offset));
        pointB_offset = max(1, min([rows, cols], pointB_offset));
        
        % Get mask using gridMaskLineSegment
        [mask, ~, ~, ~, ~] = gridMaskLineSegment(data3D(:,:,1), pointA_offset, pointB_offset);
        
        if any(mask(:))
            % Get coordinates of masked points
            [y_coords, x_coords] = find(mask);
            
            % Calculate distances along the line
            distances = sqrt((x_coords - pointA_offset(2)).^2 + (y_coords - pointA_offset(1)).^2);
            [~, sort_idx] = sort(distances);
            x_coords = x_coords(sort_idx);
            y_coords = y_coords(sort_idx);
            
            % Create 2D data array for current angle
            switch rangetype
                case 'dynamic'
                    for z = 1:size(data3D, 3)
                        values = data3D(sub2ind(size(data3D), y_coords, x_coords, z*ones(size(x_coords))));
                        % Interpolate to fixed number of points
                        interpolated = interp1(1:length(values), values, ...
                                          linspace(1,length(values),max_points));
                        % Normalize to range 0-1
                        width_data(:,z,w) = (interpolated - min(interpolated)) / (max(interpolated) - min(interpolated));
                    end
                case 'global'
                    for z = 1:size(data3D, 3)
                        values = data3D(sub2ind(size(data3D), y_coords, x_coords, z*ones(size(x_coords))));
                        % Interpolate to fixed number of points
                        interpolated = interp1(1:length(values), values, ...
                                          linspace(1,length(values),max_points));
                        % no normalization
                        width_data(:,z,w) = interpolated;
                    end
            end
        end
    end
    
    % Average the data from all parallel lines
    data2D(:,:,i) = mean(width_data, 3);
end

% Create figure with two subplots
fig = figure('Position', [100 100 1200 500]);

% First subplot: Original data with rotating line
subplot(1,2,1);
h1 = imagesc(data3D(:,:,1));
colormap gray;
axis equal;
title('Original data with line');
hold on;
h_line = plot([pointA(2), pointB(2)], [pointA(1), pointB(1)], 'r-', 'LineWidth', 2);

% Second subplot: Rotational slice data
subplot(1,2,2);
h2 = imagesc(data2D(:,:,1)');
colormap gray;
title(sprintf('Angle: %.2f° (0° = vertical)', rad2deg(angles(1))));
xlabel('Position along line');
ylabel('Energy slice');
colorbar;

% Store data in figure for callback
setappdata(fig, 'data2D', data2D);
setappdata(fig, 'data3D', data3D);
setappdata(fig, 'angles', angles);
setappdata(fig, 'center', center);
setappdata(fig, 'radius', radius);
setappdata(fig, 'h1', h1);
setappdata(fig, 'h2', h2);
setappdata(fig, 'h_line', h_line);
setappdata(fig, 'line_width', line_width);

% Add slider for angle selection
slider = uicontrol('Style', 'slider',...
    'Min', 1, 'Max', length(angles),...
    'Value', 1,...
    'Position', [20 20 400 20],...
    'Callback', @updatePlot);

% Add text showing current angle
angle_text = uicontrol('Style', 'text',...
    'Position', [430 20 100 20],...
    'String', sprintf('%.2f°', rad2deg(angles(1))));

end

% Callback function to update plot
function updatePlot(src, ~)
    % Get data from figure
    fig = ancestor(src, 'figure');
    data2D = getappdata(fig, 'data2D');
    data3D = getappdata(fig, 'data3D');
    angles = getappdata(fig, 'angles');
    center = getappdata(fig, 'center');
    radius = getappdata(fig, 'radius');
    h1 = getappdata(fig, 'h1');
    h2 = getappdata(fig, 'h2');
    h_line = getappdata(fig, 'h_line');
    line_width = getappdata(fig, 'line_width');
    
    % Get current angle index
    idx = round(src.Value);
    theta = angles(idx);
    
    % Update line endpoints
    pointA = round([center(1) + radius*cos(theta), center(2) + radius*sin(theta)]);
    pointB = round([center(1) - radius*cos(theta), center(2) - radius*sin(theta)]);
    
    % Calculate perpendicular direction for line width
    line_vec = [pointB(2) - pointA(2), pointB(1) - pointA(1)];
    line_vec = line_vec / norm(line_vec);
    perp_vec = [-line_vec(2), line_vec(1)];  % Rotate 90 degrees
    
    % Update line in first subplot (note: imagesc uses [x,y] for plot)
    set(h_line, 'XData', [pointA(2), pointB(2)], 'YData', [pointA(1), pointB(1)]);
    
    % Update second subplot
    h2.CData = data2D(:,:,idx)';
    title(sprintf('Angle: %.2f° (0° = vertical)', rad2deg(angles(idx))));
    
    % Update angle text
    set(findobj('Style', 'text'), 'String', sprintf('%.2f°', rad2deg(angles(idx))));
end 