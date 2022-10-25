function [mask, N] = gridMaskSquare(didv, Vred, imV)
%gridMaskSquare Make a mask based on rectangle drawn on didv
%   Define 2 points that makes up a rectangle the will be the mask.
%   mask = mask of selected area
%   N = number of points included in mask
%   imV = bias slice to show and click on

didv_flip = flip(permute(didv,[1 3 2]),2);

[~,imN] = min(abs(Vred-imV));

img = figure ('Name', ['Image of states at ',num2str(imV),' V']);imagesc(squeeze(didv_flip(imN,:,:)));
colormap('gray');
% colormap('summer');
% colormap(flipud(cm_magma))
hold on
axis image
% spec = figure ('Name', 'dI/dV at different points'); hold on;xlabel('Bias [V]');ylabel('dI/dV')

R = 2; %defining circles that will be drawn vin image
xx = -R:.01:R;
yy = sqrt(R^2-xx.^2);

colours = 'rgbcmyk';

p = zeros(2,2);
for k = 1:2
    figure(img)
    pos = round(ginput(1)); %click for the first point
    plot(pos(1)+xx,pos(2)+yy,colours(mod(k-1,7)+1))
    plot(pos(1)+xx,pos(2)-yy,colours(mod(k-1,7)+1))
    p(:,k) = [pos(1);pos(2)]; % columns give the point order
end

% make quadrangle from the 2 points
mask = zeros(size(didv,2),size(didv,3));
mask(min(p(1,:)):max(p(1,:)), min(p(2,:)):max(p(2,:))) = 1;

% number of points you are averaging over
[row, ~] = find(mask);
N = length(row);


end

