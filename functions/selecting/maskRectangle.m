function [mask, num_in_mask, comment] = maskRectangle(data, V_reduced, imageV)
%Description: maskRectangle creates a rectangular mask by either manual input of corner points or by clicking the coner points. 

% Parameters
%   data: 2D or 3D data
%   V_reduced: reduced vector with bias voltages(see Derivative function in PD01A for definition of V_reduced); this is
%   an optional input for the case where the "data" has a 3D structure, e.g. didv. 
%   imageV: this is an optional input for the case where the "data" has a 3D structure, e.g. didv. 
%   V_reduced and imageV will be used to select the energy slice to feed the function when the data is 3D. 

arguments
    data        
    V_reduced   = []                    % optional, only for 3D data
    imageV      = []                    % optional, only for 3D data
end

% Load colou rmaps
color_scale_resolution = 1000; % 1000 evenly spaced colour points
cm_magma = magma(color_scale_resolution);


% Check if data is 2D or 3D
dimData = ndims(data);
if dimData == 3
    % Ensure V_reduced and imageV are provided for 3D data
    if isempty(V_reduced) || isempty(imageV)
        error('For 3D data, both V_reduced and imageV are required inputs.');
    end
    
    % Select the energy slice for processing
    [~,imN] = min(abs(V_reduced-imageV));
    data_slice = data(:,:,imN); % Extract the closest slice
else
    if dimData ~= 2
        error('Data must be either 2D or 3D.');
    end
    data_slice = data;  % Use data directly for 2D case
end

% Display data and get point for mask center
img = figure('Name', 'Select Mask Location');
imagesc(data_slice');   % Our data has a structure of either (x,y,V) or (x,y,z). 
                        % In order to display the data in the same way we see in the
                        % scanning window, we need to input (y,x,V) or (y,x,z) for imagesc function. 
colormap(cm_magma);
hold on;
axis image;
axis xy;

% Prompt the user for input method in the command window
disp('Choose input method:');
disp('1: Specify coordinates (x1, y1, x2, y2) manually.');
disp('2: Click on the plot to select two corner points.');
choice = input('Enter your choice (1 or 2): ');

if choice == 1
    % User specifies coordinates
    fprintf = ('Enter the rectangle corners as [x1, y1, x2, ys]:\n');
    coords = input('Coordinates: '); % Manual input of corners
    if numel(coords) ~= 4
        error('You must provide four values: [x1, y1, x2, y2].');
    end
    x1 = coords(1);
    y1 = coords(2);
    x2 = coords(3);
    y2 = coords(4);
elseif choice == 2
    % User clicks to select two corner points
    fprintf('Click two points on the plot to define the rectangle corners.\n');
    points = round(ginputAllPlatform(2)); % Select two points
    x1 = points(1, 1);
    y1 = points(1, 2);
    x2 = points(2, 1);
    y2 = points(2, 2);
else
    error('Invalid choice. Please enter 1 or 2.');
end

% Ensure coordinates are within bounds
[rows, cols] = size(data_slice);
x1 = max(1, min(cols, x1));
x2 = max(1, min(cols, x2));
y1 = max(1, min(rows, y1));
y2 = max(1, min(rows, y2));

% Sort coordinates to define the rectangle correctly
x_min = min(x1, x2);
x_max = max(x1, x2);
y_min = min(y1, y2);
y_max = max(y1, y2);

% Highlight the rectangle on the plot
rectangle('Position', [x_min, y_min, x_max - x_min, y_max - y_min], ...
          'EdgeColor', 'g', 'LineWidth', 0.6);

% Create the mask matrix
mask = false(size(data_slice));
mask(y_min:y_max, x_min:x_max) = true;  % Similar to imagesc, we need to input (y,x) in order to 
                                        % creat a proper mesh corresponding to our data format.

% Count number of points in the mask
num_in_mask = nnz(mask);

hold off;

% Include details in the comment output 
if dimData == 3
    comment = sprintf("maskRectangle(data:%s, x1=%d, y1=%d, x2=%d, y2=%d, V_reduced:%s, imageV=%s)", ...
                      mat2str(size(data)), x1, y1, x2, y2, ...
                      mat2str(size(V_reduced)), num2str(imageV));
else
    comment = sprintf("maskRectangle(data:%s, x1=%d, y1=%d, x2=%d, y2=%d)", ...
                      mat2str(size(data)), x1, y1, x2, y2);
end
end

