function [mask, Num_in_mask, comment] = gridMaskPoint_historical(didv, V_reduced, imageV, radius)
%Description: gridMaskPoint create a mask of radius R around the clicked point.
% Note: this function logs the click position (x, y) corretly and the corresponding circular mask is created 
% at the proper location. However, when you open the output "mask", it looks like the mask position
% (non-zero rows and columns) is located at (x, y_max - y). This is not an error. 
% This is just how MatLab handles rows and columns. 

% Parameters
%   didv: 3D Matrix with dI/dV data
%   V_reduced: reduced vector with bias voltages(see gridCorNorm for definition of V_reduced)
%   imageV: float, voltage at which to display image 
%   radius: float, radius of mask (pixels)

% load colourmap
color_scale_resolution = 1000; % 1000 evenly spaced colour points
cm_viridis = viridis(color_scale_resolution); % Default matlibplot
cm_inferno = inferno(color_scale_resolution);
cm_magma = magma(color_scale_resolution);
cm_plasma = plasma(color_scale_resolution);

didv_flip = flip(permute(didv,[1 3 2]),2);

[~,imN] = min(abs(V_reduced-imageV));

img = figure('Name', ['Image of states at ',num2str(imageV),' V']);
clims = [0,3E-9];
imagesc(squeeze(didv_flip(imN,:,:)),clims);
colormap(cm_magma)
hold on
axis image

xx = -radius:.01:radius;
yy = sqrt(radius^2-xx.^2);

%Drawing the mask(circle) on LDOS map at certain bias
figure(img)
pos = round(ginputAllPlatform(1)); %click for the first point
%pos = round(ginput(1)); %click for the first point
plot(pos(1)+xx,pos(2)+yy,'g','LineWidth',0.6)
plot(pos(1)+xx,pos(2)-yy,'g','LineWidth',0.6)

% make the mask at point
mask = zeros(size(didv,2),size(didv,3));
mask((-radius:radius)+pos(1),(-radius:radius)+(size(mask,2)-pos(2))) = logical(fspecial('disk',radius));

% number of points you are averaging over
[row, ~] = find(mask);
Num_in_mask = length(row);

hold off

% the x, y coordinate from the click are also included in the comment. 
comment = sprintf("gridMaskPoint(didv:%s, V_reduced:%s, imageV=%s, radius=%s, x=%s, y=%s)", mat2str(size(didv)), mat2str(size(V_reduced)), num2str(imageV), num2str(radius), num2str(pos(1)), num2str(pos(2)));
end

