function [mask, num_in_mask, comment] = gridMaskRectangle(didv, V_reduced, imageV, cornerPoints)
% This function create a rectangular mask 
% Given 2 points, this function creates a rectangular mask in the area defined by the 2 points.   

% Parameters
%   didv: 3D Matrix with dI/dV data in the format: (x,y,V)
%   V_reduced: reduced vector with bias voltages(see Derivative function in PD01A for definition of V_reduced)
%   imageV: float, voltage at which to display image 
%   radius: float, radius of mask (pixels)

arguments
    didv        {mustBeNumeric}
    V_reduced   {mustBeVector}
    imageV      {mustBeNumeric}
    cornerPoints {mustBeNumeric} = []
end 
    
% load colourmap
color_scale_resolution = 1000; % 1000 evenly spaced colour points
cm_viridis = viridis(color_scale_resolution); % Default matlibplot
cm_inferno = inferno(color_scale_resolution);
cm_magma = magma(color_scale_resolution);
cm_plasma = plasma(color_scale_resolution);

[~,imN] = min(abs(V_reduced-imageV));

img = figure('Name', ['Image of states at ',num2str(imageV),' V']);

    

% Display the data map and get corner points if not provided
if nargin < 2 || isempty(cornerPoints)
    imagesc(didv(:,:,imN));
    colormap(cm_magma)
    hold on
    axis image
    cornerPoints = ginputAllPlatform(2); % Get two points from the user
else
    if size(cornerPoints, 1) ~= 2 || size(cornerPoints, 2) ~= 2
        error('Corner points must be a 2x2 matrix');
    end
end
    
% Round points from ginputALLplatform or manual input
cornerPoints = round(cornerPoints);
    
% Check if the provided corner points are within the data bounds
if any(cornerPoints(:,1) < 1 | cornerPoints(:,1) > cols | ...
    cornerPoints(:,2) < 1 | cornerPoints(:,2) > rows)
    error('Corner points must be within the dimensions of the data');
end

x = cornerPoints(:, 1);
y = cornerPoints(:, 2);

% Define the corners of the rectangle
x1 = min(x);
x2 = max(x);
y1 = min(y);
y2 = max(y);

% Initialize the mask
mask = zeros(size(didv,1),size(didv,2));

% Fill in the rectangle in the mask
mask(y1:y2, x1:x2) = true;

% Count the number of points in the mask
num_in_mask = sum(mask(:));

% Format the chosen points for inclusion in the comment
chosenPointsStr = sprintf('[%.2f, %.2f; %.2f, %.2f]', cornerPoints(1,1), cornerPoints(1,2), cornerPoints(2,1), cornerPoints(2,2));

% Generate the comment, referring to 'data' generically
comment = sprintf('gridMaskRectangle called with data of size [%d, %d] and corner points %s.', size(data, 1), size(data, 2), chosenPointsStr);
end

