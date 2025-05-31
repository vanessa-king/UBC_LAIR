function [mask, masked_data, masked_qpi, comment] = qpiMask(grid_data, slice_idx, mode, sigma, operation_mode)
% QPIMASK Creates a center-symmetric mask for QPI data and applies it
%   This function allows users to select regions in QPI data and automatically
%   creates a center-symmetric mask. Users can choose between circular and
%   rectangular regions.
%   The symmetry is applied across the origin (0,0) in k-space, which is at the
%   center of the FFT-shifted data.
%
% Inputs:
%   grid_data - 3D array of real-space grid data
%   slice_idx - (Optional) Index of the slice to use for region selection.
%              If not provided, displays the full 3D dataset for selection.
%   mode - (Optional) Mask mode:
%          'binary' - Binary mask (1 for unmasked, 0 for masked regions)
%          'gaussian_window' - Gaussian window centered at the origin
%   sigma - (Optional) Standard deviation for Gaussian window. Required if mode is 'gaussian_window'
%   operation_mode - (Optional) Operation mode:
%                   'remove' - Remove the masked regions (default)
%                   'select' - Keep only the masked regions
%
% Outputs:
%   mask - 2D array containing the center-symmetric mask (in q-space)
%   masked_data - 3D array containing the masked real-space data
%   masked_qpi - 3D array containing the masked QPI data
%   comment - String containing function call details and region information
%
% Example:
%   [mask, masked_data, masked_qpi, comment] = qpiMask(grid_data);  % Binary mask, remove mode
%   [mask, masked_data, masked_qpi, comment] = qpiMask(grid_data, 1, 'gaussian_window', 2, 'select');  % Gaussian window with sigma=2, select mode
%
% Created: May 2025

% Validate inputs
arguments
    grid_data {mustBeNumeric}
    slice_idx {mustBeInteger, mustBePositive} = 1
    mode {mustBeMember(mode, {'binary', 'gaussian_window'})} = 'binary'
    sigma {mustBeNumeric, mustBePositive} = []
    operation_mode {mustBeMember(operation_mode, {'remove', 'select'})} = 'remove'
end

% Validate sigma for gaussian_window mode
if strcmp(mode, 'gaussian_window') && isempty(sigma)
    error('Sigma must be specified for gaussian_window mode');
end

% Get image dimensions
[rows, cols, ~] = size(grid_data);
center_row = floor(rows/2)+1;
center_col = floor(cols/2)+1;

% Transform input data to q-space
QPI = zeros(size(grid_data));
for i = 1:size(grid_data,3)
    QPI(:,:,i) = fftshift(fft2(grid_data(:,:,i)));
end
QPI_logabs = log(abs(QPI));  % Take log of absolute value for display

% Display the data
if isempty(slice_idx)
    % Display full 3D dataset
    figure;
    d3gridDisplay(QPI_logabs, 'dynamic');
    slice_idx = input('Enter the slice number to select regions: ');
    if isempty(slice_idx) || slice_idx < 1 || slice_idx > size(QPI, 3)
        error('Invalid slice number');
    end
    close;  % Close the d3gridDisplay figure
end

% Display the selected slice for user to select regions
figure;
imagesc(QPI_logabs(:,:,slice_idx)); 
axis image; 
colormap hot; 
title('Select regions to mask (center symmetry will be applied automatically)');
hold on;
% Plot center point for reference
plot(center_col, center_row, 'w+', 'MarkerSize', 10, 'LineWidth', 2);

% Initialize variables
num_regions = input('Enter the number of unique regions to process: ');
mask = ones(rows, cols);

% Ask user for region type
region_type = input('Choose region type (1 for circle, 2 for rectangle): ');

% Initialize cell array to store region information
region_info = cell(num_regions, 1);

% Initialize array to store all region handles
all_region_handles = [];

% Let user select each region
for i = 1:num_regions
    disp(['Select region #', num2str(i)]);
    
    switch region_type
        case 1 % Circle
            % Let user draw a circular ROI
            h = drawcircle('Color', 'b');
            wait(h);
            
            % Get ROI properties
            center = h.Center;  % [x y]
            radius = h.Radius;
            
            % Calculate center-symmetric point (q-space inversion symmetry)
            sym_center_x = 2*center_row - center(1);
            sym_center_y = 2*center_col - center(2);
            
            % Store region information
            region_info{i} = struct('type', 'circle', ...
                                  'center', center, ...
                                  'radius', radius, ...
                                  'sym_center', [sym_center_x, sym_center_y]);
            
            % Create center point markers
            hold on;
            h_marker = plot(center(1), center(2), 'g+', 'MarkerSize', 10);
            sym_marker = plot(sym_center_x, sym_center_y, 'g+', 'MarkerSize', 10);
            
            % Create and display the symmetric circle
            sym_h = drawcircle('Center', [sym_center_x, sym_center_y], ...
                             'Radius', radius, ...
                             'Color', 'b');
            
            % Enable interactive mode for both circles
            h.InteractionsAllowed = 'all';
            sym_h.InteractionsAllowed = 'all';
            
            % Add listeners to keep circles and markers synchronized
            addlistener(h, 'MovingROI', @(src,evt) updateCircleAndMarker(src, sym_h, sym_marker, h_marker, rows, cols));
            addlistener(sym_h, 'MovingROI', @(src,evt) updateCircleAndMarker(src, h, h_marker, sym_marker, rows, cols));
            
            % Wait for user to confirm both circles
            disp('Adjust the circles as needed. Press any key when done...');
            pause;
            
            % Get final positions and properties
            center = h.Center;
            radius = h.Radius;
            sym_center = sym_h.Center;
            
            % Draw permanent circles on the plot
            theta = linspace(0, 2*pi, 100);
            x1 = center(1) + radius * cos(theta);
            y1 = center(2) + radius * sin(theta);
            x2 = sym_center(1) + radius * cos(theta);
            y2 = sym_center(2) + radius * sin(theta);
            
            % Add to plot and store handles
            h1 = plot(x1, y1, 'g-', 'LineWidth', 2);
            h2 = plot(x2, y2, 'g-', 'LineWidth', 2);
            all_region_handles = [all_region_handles, h1, h2];
            
            % Create circular masks
            [X_grid, Y_grid] = meshgrid(1:cols, 1:rows);
            
            if strcmp(mode, 'binary')
                % Binary mask
                circle_mask = ((X_grid - center(1)).^2 + (Y_grid - center(2)).^2) <= radius^2;
                sym_circle_mask = ((X_grid - sym_center(1)).^2 + (Y_grid - sym_center(2)).^2) <= radius^2;
                region_mask = 1 - (circle_mask | sym_circle_mask);
            else % gaussian_window
                % Create binary masks for regions
                circle_mask = ((X_grid - center(1)).^2 + (Y_grid - center(2)).^2) <= radius^2;
                sym_circle_mask = ((X_grid - sym_center(1)).^2 + (Y_grid - sym_center(2)).^2) <= radius^2;
                
                % Create Gaussian windows within the regions
                gaussian_window = exp(-((X_grid - center(1)).^2 + (Y_grid - center(2)).^2)/(2*sigma^2));
                sym_gaussian_window = exp(-((X_grid - sym_center(1)).^2 + (Y_grid - sym_center(2)).^2)/(2*sigma^2));
                
                % Apply Gaussian windows only within the selected regions
                region_mask = ones(rows, cols);
                region_mask(circle_mask) = 1 - gaussian_window(circle_mask);
                region_mask(sym_circle_mask) = 1 - sym_gaussian_window(sym_circle_mask);
            end
            
            % Clean up
            delete(h);
            delete(sym_h);
            delete(h_marker);
            delete(sym_marker);
            
            
        case 2 % Rectangle
            % Let user draw a rectangular ROI
            h = drawrectangle('Color', 'b');
            wait(h);
            
            % Get ROI properties
            position = h.Position;  % [x y width height]
            center = [position(1) + position(3)/2, position(2) + position(4)/2];
            width = position(3);
            height = position(4);
            rotation = h.RotationAngle;
            
            % Calculate center-symmetric point (q-space inversion symmetry)
            sym_center_x = 2*center_row - center(1);
            sym_center_y = 2*center_col - center(2);
            
            % Store region information
            region_info{i} = struct('type', 'rectangle', ...
                                  'center', center, ...
                                  'width', width, ...
                                  'height', height, ...
                                  'rotation', rotation, ...
                                  'sym_center', [sym_center_x, sym_center_y]);
            
            % Create center point markers
            hold on;
            h_marker = plot(center(1), center(2), 'g+', 'MarkerSize', 10);
            sym_marker = plot(sym_center_x, sym_center_y, 'g+', 'MarkerSize', 10);
            
            % Create and display the symmetric rectangle
            sym_h = drawrectangle('Position', [sym_center_x - width/2, sym_center_y - height/2, width, height], ...
                                'RotationAngle', rotation, ...
                                'Color', 'b');
            
            % Enable interactive mode for both rectangles
            h.InteractionsAllowed = 'all';
            sym_h.InteractionsAllowed = 'all';
            
            % Add listeners to keep rectangles and markers synchronized
            addlistener(h, 'MovingROI', @(src,evt) updateRectangleAndMarker(src, sym_h, sym_marker, h_marker, rows, cols));
            addlistener(sym_h, 'MovingROI', @(src,evt) updateRectangleAndMarker(src, h, h_marker, sym_marker, rows, cols));
            
            % Wait for user to confirm both rectangles
            disp('Adjust the rectangles as needed. Press any key when done...');
            pause;
            
            % Get final positions and properties
            position = h.Position;
            center = [position(1) + position(3)/2, position(2) + position(4)/2];
            width = position(3);
            height = position(4);
            rotation = h.RotationAngle;
            sym_position = sym_h.Position;
            sym_center = [sym_position(1) + sym_position(3)/2, sym_position(2) + sym_position(4)/2];
            
            % Draw permanent rectangles on the plot
            % Original rectangle
            rect1 = rectangle('Position', position, 'EdgeColor', 'g', 'LineWidth', 2, 'Rotation', rotation);
            % Mirrored rectangle
            rect2 = rectangle('Position', sym_position, 'EdgeColor', 'g', 'LineWidth', 2, 'Rotation', rotation);
            
            % Add to plot and store handles
            all_region_handles = [all_region_handles, rect1, rect2];
            
            % Update region information with final positions
            region_info{i}.center = center;
            region_info{i}.width = width;
            region_info{i}.height = height;
            region_info{i}.rotation = rotation;
            region_info{i}.sym_center = sym_center;
            
            % Create rectangular masks
            [X_grid, Y_grid] = meshgrid(1:cols, 1:rows);
            
            % Rotate coordinates
            theta = deg2rad(rotation);
            X_rot = (X_grid - center(1)) * cos(theta) + (Y_grid - center(2)) * sin(theta);
            Y_rot = -(X_grid - center(1)) * sin(theta) + (Y_grid - center(2)) * cos(theta);
            
            if strcmp(mode, 'binary')
                % Binary mask
                rect_mask = (abs(X_rot) <= width/2) & (abs(Y_rot) <= height/2);
                
                % Rotate coordinates for symmetric point
                X_sym_rot = (X_grid - sym_center(1)) * cos(theta) + (Y_grid - sym_center(2)) * sin(theta);
                Y_sym_rot = -(X_grid - sym_center(1)) * sin(theta) + (Y_grid - sym_center(2)) * cos(theta);
                
                % Create symmetric rectangle mask
                sym_rect_mask = (abs(X_sym_rot) <= width/2) & (abs(Y_sym_rot) <= height/2);
                
                % Combine the masks
                region_mask = 1 - (rect_mask | sym_rect_mask);
            else % gaussian_window
                % Create binary masks for regions
                rect_mask = (abs(X_rot) <= width/2) & (abs(Y_rot) <= height/2);
                
                % Rotate coordinates for symmetric point
                X_sym_rot = (X_grid - sym_center(1)) * cos(theta) + (Y_grid - sym_center(2)) * sin(theta);
                Y_sym_rot = -(X_grid - sym_center(1)) * sin(theta) + (Y_grid - sym_center(2)) * cos(theta);
                
                % Create symmetric rectangle mask
                sym_rect_mask = (abs(X_sym_rot) <= width/2) & (abs(Y_sym_rot) <= height/2);
                
                % Create Gaussian windows within the regions
                gaussian_window = exp(-(X_rot.^2/(2*(width/2)^2) + Y_rot.^2/(2*(height/2)^2)));
                sym_gaussian_window = exp(-(X_sym_rot.^2/(2*(width/2)^2) + Y_sym_rot.^2/(2*(height/2)^2)));
                
                % Apply Gaussian windows only within the selected regions
                region_mask = ones(rows, cols);
                region_mask(rect_mask) = 1 - gaussian_window(rect_mask);
                region_mask(sym_rect_mask) = 1 - sym_gaussian_window(sym_rect_mask);
            end
            
            % Clean up
            delete(h);
            delete(sym_h);
            delete(h_marker);
            delete(sym_marker);
    end
    
    % Update the overall mask
    mask = mask .* region_mask;
end

close;

% Apply the mask to all slices
masked_qpi = zeros(size(QPI));
masked_data = zeros(size(grid_data));
for i = 1:size(QPI, 3)
    if strcmp(operation_mode, 'remove')
        % Remove mode: apply mask to remove selected regions
        masked_qpi(:,:,i) = QPI(:,:,i) .* mask;
    else
        % Select mode: keep only the selected regions
        masked_qpi(:,:,i) = QPI(:,:,i) .* (1 - mask);
    end
    % Inverse Fourier transform to get the filtered image
    masked_data(:,:,i) = real(ifft2(ifftshift(masked_qpi(:,:,i))));
end

% Display the result
figure;
subplot(2,2,1); imagesc(grid_data(:,:,slice_idx)); axis image; title('Original Image');
subplot(2,2,2); imagesc(QPI_logabs(:,:,slice_idx)); axis image; title('Original FFT');
subplot(2,2,3); imagesc(masked_data(:,:,slice_idx)); axis image; title(sprintf('Filtered Image (%s mode)', operation_mode));
subplot(2,2,4); imagesc(log(abs(masked_qpi(:,:,slice_idx)))); axis image; title(sprintf('Filtered FFT (%s mode)', operation_mode));

% Create comment string with function call details and region information
% Determine region type string
if region_type == 1
    region_type_str = 'circle';
else
    region_type_str = 'rectangle';
end

% Create a single comment string with all information
if strcmp(mode, 'binary')
    comment = sprintf("qpiMask(grid_data(:,:,%d), %d, 'binary', [], '%s'); Region type: %s, Number of regions: %d", ...
        slice_idx, slice_idx, operation_mode, region_type_str, num_regions);
else
    comment = sprintf("qpiMask(grid_data(:,:,%d), %d, 'gaussian_window', %.2f, '%s'); Region type: %s, Number of regions: %d", ...
        slice_idx, slice_idx, sigma, operation_mode, region_type_str, num_regions);
end

% Add details for each region
for i = 1:num_regions
    if strcmp(region_info{i}.type, 'circle')
        comment = sprintf("%s\nRegion %d (circle): center=[%.2f,%.2f], radius=%.2f", ...
            comment, i, region_info{i}.center(1), region_info{i}.center(2), region_info{i}.radius);
    else
        comment = sprintf("%s\nRegion %d (rectangle): center=[%.2f,%.2f], width=%.2f, height=%.2f", ...
            comment, i, region_info{i}.center(1), region_info{i}.center(2), region_info{i}.width, ...
            region_info{i}.height);
    end
end

% Helper function for circle synchronization
function updateCircleAndMarker(src, target, marker, src_marker, rows, cols)
    % Calculate distances from source point to edges
    dist_to_left = src.Center(1) - 1;
    dist_to_top = src.Center(2) - 1;
    
    % The symmetric point should have the same distances but to opposite edges
    sym_center = [cols - dist_to_left, rows - dist_to_top];
    
    % Update target circle position
    target.Center = sym_center;
    target.Radius = src.Radius;
    
    % Update both marker positions
    src_marker.XData = src.Center(1);
    src_marker.YData = src.Center(2);
    marker.XData = sym_center(1);
    marker.YData = sym_center(2);
end

% Helper function for rectangle synchronization
function updateRectangleAndMarker(src, target, marker, src_marker, rows, cols)
    % Calculate distances from source point to edges
    dist_to_left = src.Position(1) - 1;
    dist_to_top = src.Position(2) - 1;
    
    % The symmetric point should have the same distances but to opposite edges
    sym_center = [cols - dist_to_left, rows - dist_to_top];
    
    % Update target rectangle position and properties
    target.Position = [sym_center(1) - src.Position(3)/2, sym_center(2) - src.Position(4)/2, src.Position(3), src.Position(4)];
    target.RotationAngle = src.RotationAngle;
    
    % Update both marker positions
    src_marker.XData = src.Position(1) + src.Position(3)/2;
    src_marker.YData = src.Position(2) + src.Position(4)/2;
    marker.XData = sym_center(1);
    marker.YData = sym_center(2);
end

end 