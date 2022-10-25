%Description: gridMaskPoint Create mask of radius R around clicked point

function [mask, Num_in_mask] = gridMaskPoint(didv, V_reduced, imageV, radius)

%Parameters
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
% colormap('gray');
colormap(cm_magma)
hold on
axis image

xx = -radius:.01:radius;
yy = sqrt(radius^2-xx.^2);

%Drawing the mask(circle) on LDOS map at certain bias
figure(img)
pos = round(ginput(1)); %click for the first point
plot(pos(1)+xx,pos(2)+yy,'r','LineWidth',0.6)
plot(pos(1)+xx,pos(2)-yy,'r','LineWidth',0.6)

% make the mask at point
mask = zeros(size(didv,2),size(didv,3));
mask((-radius:radius)+pos(1),(-radius:radius)+(size(mask,2)-pos(2))) = logical(fspecial('disk',radius));

% number of points you are averaging over
[row, ~] = find(mask);
Num_in_mask = length(row);

% close(gcf);

end

