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
%   Note that skew results in a larger grid. Extra elements are left as 0.
%   The x,y scale for the topography and grid are extended linearly to
%   accomodate.

% To be edited: make before and after topo images, instead of grid
% structures 
function [gridCorrected,comment] = gridDriftCorrection(grid, before, after, theta)

arguments
    grid          
    before
    after      
    theta = 0
end

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Never plot data (e.g. the whole grid) in the comment, only plot the values
%('=<VARn_value>') of variables that decide/affect how the function
%processes data (e.g. order of fit, ...) 
%Note convert all <VARn_value> to strings; 
formatSpec = "gridDriftCorrection(grid: %s, before: %s, after: %s, theta=%.3g degrees)|";
comment = sprintf(formatSpec,mat2str(size(grid)), mat2str(size(before)), mat2str(size(after)), theta);

%regular function processing:

% segment the image
level = graythresh(mat2gray(before.z_img));
before_image = double(imbinarize(mat2gray(before.z_img),level));
after_image = double(imbinarize(mat2gray(after.z_img),level));

%blend the before and after image together and plot
halphablend = vision.AlphaBlender;
img12 = halphablend(after_image,before_image);
figure;
hold on;
title('Before and after scans, segmented')
imagesc(img12');
axis image;
axis xy;
hold off;

%identify 'objects' in the images
before = regionprops(before_image,'centroid');
before_objects = before.Centroid;
after = regionprops(after_image,'centroid');
after_objects = after.Centroid;

%calculate linear shear to compensate drift
drift = after_objects - before_objects; 
theta = deg2rad(theta);

z = grid.z_img;
x_drift = -drift(1)/size(z,1);
y_drift = -drift(2)/size(z,2);
transform = affine2d([cos(theta)-y_drift*sin(theta), sin(theta)+y_drift*cos(theta), 0; ...
    x_drift*cos(theta)-sin(theta), x_drift*sin(theta)+cos(theta), 0; ...
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
