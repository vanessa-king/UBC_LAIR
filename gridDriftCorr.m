function [gridcorr] = gridDriftCorr(grid, before, after, theta)
%GRIDDRIFTCORR Correct for drift over time in grid IV spectroscopy.
%   Calculates the drift from before and after topography images and skews
%   the iv grid to compensate. You can rotate by angle theta (deg) if you
%   so choose.
%   Input: 
%   - grid: original data structure from gridLoadData
%   - before: topography structure from topoLoadData of image before  taking the grid
%   - after: topography strcutre from topoLoadData of image after the grid
%   - theta: angle theta to rotate (in degrees)
%   
%   Output:
%   - gridcorr: structure with same fields as grid, but with drift corrected
%
%   Note that skew results in larger grid. Extra elements are left as 0.
%   The x,y scale for the topography and grid are extended linearly to accomodate.

% segment the image and track the motion
level = graythresh(mat2gray(before.z_img));
bef_img = double(imbinarize(mat2gray(before.z_img),level)); % imbinarize: Binarize 2-D grayscale image 
aft_img = double(imbinarize(mat2gray(after.z_img),level)); 
%bef: before, aft: after

bef = regionprops(bef_img,'centroid'); %regionprops: Measure properties of image regions
aft = regionprops(aft_img,'centroid');


drift_distance = aft.Centroid - bef.Centroid; 
theta_in_radian = deg2rad(theta);

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
z = grid.z_img;
xshift = -drift_distance(1)/size(z,1);
yshift = -drift_distance(2)/size(z,2);
transform = affine2d([cos(theta_in_radian)-yshift*sin(theta_in_radian), sin(theta_in_radian)+yshift*cos(theta_in_radian), 0; ...
    xshift*cos(theta_in_radian)-sin(theta_in_radian), xshift*sin(theta_in_radian)+cos(theta_in_radian), 0; ...
    0, 0, 1]);
z_img = imwarp(z,transform);
temp = imwarp(squeeze(grid.iv(1,:,:)),transform);
iv = zeros(length(grid.V),size(temp,1), size(temp,2));
for i = 1:length(grid.V)
    iv(i,:,:) = imwarp(squeeze(grid.iv(i,:,:)),transform);
end

% redefine x and y axis, distances should be preserved
x_img = linspace(0,mean(diff(grid.x_img))*size(z_img,1),size(z_img,1));
y_img = linspace(0,mean(diff(grid.y_img))*size(z_img,2),size(z_img,2));
x = linspace(0,mean(diff(grid.x))*size(iv,2),size(iv,2));
y = linspace(0,mean(diff(grid.y))*size(iv,3),size(iv,3));

% assign values
gridcorr.x_img = x_img;
gridcorr.y_img = y_img;
gridcorr.z_img = z_img;
gridcorr.x = x;
gridcorr.y = y;
gridcorr.V = grid.V;
gridcorr.iv = iv;


% plot preview
figure; 
hold on;
imagesc(gridcorr.x_img, gridcorr.y_img, gridcorr.z_img',[min(z(:)),max(z(:))]);
title('Z topography (drift corrected)');
xlabel('x / nm');ylabel('y / nm');
axis image;
axis xy;
hold off;

end
