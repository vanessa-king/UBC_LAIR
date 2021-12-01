function [mask, N] = gridMaskPoint(didv, Vred, imV, R)
%gridMaskPoint Create mask of radius R around clicked point
%   mask = selected area
%   N = number of points in mask
%   imV = bias slice to show and click on
%   R = radius of mask (pixels)

% load colourmap
m = 1000; % 1000 evenly spaced colour points
cm_viridis = viridis(m); % Default matlibplot
cm_inferno = inferno(m);
cm_magma = magma(m);
cm_plasma = plasma(m);

didv_flip = flip(permute(didv,[1 3 2]),2);

[~,imN] = min(abs(Vred-imV));

img = figure('Name', ['Image of states at ',num2str(imV),' V']);
clims = [0,3E-9];
imagesc(squeeze(didv_flip(imN,:,:)),clims);
% colormap('gray');
colormap(cm_magma)
hold on
axis image

xx = -R:.01:R;
yy = sqrt(R^2-xx.^2);

%Confused about here
figure(img)
pos = round(ginput(1)); %click for the first point
plot(pos(1)+xx,pos(2)+yy,'r','LineWidth',0.6)
plot(pos(1)+xx,pos(2)-yy,'r','LineWidth',0.6)

% make the mask at point
mask = zeros(size(didv,2),size(didv,3));
mask((-R:R)+pos(1),(-R:R)+(size(mask,2)-pos(2))) = logical(fspecial('disk',R));

% number of points you are averaging over
[row, ~] = find(mask);
N = length(row);

% close(gcf);

end

