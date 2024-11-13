function [mask, num_in_mask, data_slice, comment] = maskPoint(data, radius, V_reduced, imageV)
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
imagesc(data_slice);
colormap(cm_magma);
hold on;
axis image;
axis xy;

% Draw the mask circle on the image
xx = -radius:0.01:radius;
yy = sqrt(radius^2-xx.^2);
pos = round(ginputAllPlatform(1)); % Click to select center point
plot(pos(1) + xx, pos(2) + yy,'g','LineWidth',0.6)
plot(pos(1) + xx, pos(2) - yy,'g','LineWidth',0.6)

% Create mask matrix and apply circular mask centered at pos
mask = zeros(size(data_slice,1),size(data_slice,2));
mask((-radius:radius)+pos(1),(-radius:radius)+pos(2)) = logical(fspecial('disk',radius));

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

