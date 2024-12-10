function [mask, num_in_mask, comment] = maskPoint(data, radius, V_reduced, imageV)
%Description: maskPoint creates a circular mask of a specified radius around the clicked point.

% Parameters
%   data: 2D or 3D data
%   radius: float, radius of mask (pixels)
%   V_reduced: reduced vector with bias voltages(see Derivative function in PD01A for definition of V_reduced); this is
%   an optional input for the case where the "data" has a 3D structure, e.g. didv. 
%   imageV: this is an optional input for the case where the "data" has a 3D structure, e.g. didv. 
%   V_reduced and imageV will be used to select the energy slice to feed the function when the data is 3D. 

arguments
    data        
    radius      {mustBeNumeric,mustBePositive}
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
disp('1: Specify coordinates (x, y) manually.');
disp('2: Click on the plot to select the center.');
choice = input('Enter your choice (1 or 2): ');

if choice == 1
    % User specifies coordinates
    pos = input('Enter the coordinates as [x, y]: ');
elseif choice == 2
    % User clicks to select the center
    pos = round(ginputAllPlatform(1)); % Click to select center point
else
    error('Invalid choice. Please enter 1 or 2.');
end

% Check if the circle is within the image boundaries
x_min = pos(1) - radius;
x_max = pos(1) + radius;
y_min = pos(2) - radius;
y_max = pos(2) + radius;

if x_min < 1 || y_min < 1 || x_max > size(data_slice, 1) || y_max > size(data_slice, 2)
    error('The circle exceeds the image boundaries. Please select a point closer to the center of the image.');
end

% Draw the mask circle on the image
xx = -radius:0.01:radius;
yy = sqrt(radius^2-xx.^2);
plot(pos(1) + xx, pos(2) + yy,'g','LineWidth',0.6)
plot(pos(1) + xx, pos(2) - yy,'g','LineWidth',0.6)

% Create mask matrix and apply circular mask centered at pos
mask = zeros(size(data_slice,1),size(data_slice,2));
[X, Y] = meshgrid(1:size(data_slice, 2), 1:size(data_slice, 1)); % Similar to imagesc, we need to input (y,x) in order to 
                                                                 % creat a proper mesh corresponding to our data format.
mask((X - pos(2)).^2 + (Y - pos(1)).^2 <= radius^2) = 1;    % For the same reason stated above, the input here needs to be (y,x).

% Count number of points in the mask
num_in_mask = nnz(mask);

hold off;

% Include details in the comment output 
if dimData == 3
    comment = sprintf("maskPoint(data:%s, radius=%s, x=%s, y=%s, V_reduced:%s, imageV=%s)", ...
                      mat2str(size(data)), num2str(radius), num2str(pos(1)), num2str(pos(2)), ...
                      mat2str(size(V_reduced)), num2str(imageV));
else
    comment = sprintf("maskPoint(data:%s, radius=%s, x=%s, y=%s)", ...
                      mat2str(size(data)), num2str(radius), num2str(pos(1)), num2str(pos(2)));
end
end