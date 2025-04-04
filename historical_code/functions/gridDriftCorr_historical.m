function [gridCorrected,comment] = gridDriftCorr_historical(grid, before, after, theta)
%   Correct for drift over time in a grid map.
%   Calculates the drift from before and after topography images and skews
%   the iv grid to compensate. You can rotate by angle theta (deg) if you
%   so choose.
%   Input: 
%   - grid: original data structure from gridLoadData
%   - before: topography structure from topoLoadData of image before grid
%   - after: topography structure from topoLoadData of image after grid
%   - theta: angle to rotate the grid (in degrees)
%   
%   Output:
%   - gridCorrected: structure with same fields as grd, but with drift corrected
%
%   Note that skew results in larger grid. Extra elements are left as 0.
%   The x,y scale for the topography and grid are extended linearly to
%   accomodate.

% To be edited: make before and after topo images, instead of grid
% structures 

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)"  
%Note convert all <VARn_value> to strings; 
formatSpec = "gridDriftCorr(grid: %s, before: %s, after: %s, theta=%.3g degrees)|";
comment = sprintf(formatSpec,mat2str(size(grid)), mat2str(size(before)), mat2str(size(after)), theta);

% segment the image and track the motion
level = graythresh(mat2gray(before.z_img));
bef_img = double(imbinarize(mat2gray(before.z_img),level));
aft_img = double(imbinarize(mat2gray(after.z_img),level));

bef = regionprops(bef_img,'centroid');
bef_c = bef.Centroid;
aft = regionprops(aft_img,'centroid');
aft_c = aft.Centroid;

pdist = aft_c - bef_c; 
t = deg2rad(theta);

halphablend = vision.AlphaBlender;
img12 = halphablend(aft_img,bef_img);
figure;
hold on;
title('Before and after scans, segmented')
imagesc(img12');
axis image;
axis xy;
hold off;

% linear shear to compensate drift
z = grd.z_img;
xshift = -pdist(1)/size(z,1);
yshift = -pdist(2)/size(z,2);
tform = affine2d([cos(t)-yshift*sin(t), sin(t)+yshift*cos(t), 0; ...
    xshift*cos(t)-sin(t), xshift*sin(t)+cos(t), 0; ...
    0, 0, 1]);
z_img = imwarp(z,tform);
temp = imwarp(squeeze(grid.iv(1,:,:)),tform);
iv = zeros(length(grid.V),size(temp,1), size(temp,2));
for i = 1:length(grid.V)
    iv(i,:,:) = imwarp(squeeze(grid.iv(i,:,:)),tform);
end

% redefine x and y axis, distances should be preserved
x_img = linspace(0,mean(diff(grid.x_img))*size(z_img,1),size(z_img,1));
y_img = linspace(0,mean(diff(grid.y_img))*size(z_img,2),size(z_img,2));
x = linspace(0,mean(diff(grid.x))*size(iv,2),size(iv,2));
y = linspace(0,mean(diff(grid.y))*size(iv,3),size(iv,3));

% assign values
gridCorrected.x_img = x_img;
gridCorrected.y_img = y_img;
gridCorrected.z_img = z_img;
gridCorrected.x = x;
gridCorrected.y = y;
gridCorrected.V = grid.V;
gridCorrected.iv = iv;


% plot preview
figure; 
hold on;
imagesc(gridCorrected.x_img, gridCorrected.y_img, gridCorrected.z_img',[min(z(:)),max(z(:))]);
title('Z topography (drift corrected)');
xlabel('x / nm');ylabel('y / nm');
axis image;
axis xy;
hold off;

end
