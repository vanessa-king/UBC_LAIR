function topo = topoPlaneSub(image,n,plot)
%TOPOPLANESUB Subtracts the plane in topography images from Omicron STM.--- Q
%   Takes an image, and randomly sample n points. A plane is fitted to these points, and subtracted from the image. 
%   image - the structure file generated from topoLoadData.m (structure)
%   n - number of points to sample, the default number is 200 (integer)
%   plot - choose to plot the process of plane sub, the is default is F (boolean)----Q
%
%   Outputs a single z matrix with the plane subtracted.

% select mode of operation
if nargin == 1
    n = 200; plot = 0;
elseif nargin == 2
    plot = 0;
end
    
% auto plane subtract
% subtract a plane
xsamp = round(rand(n,1)*(numel(image.x_img)-1))+1;
ysamp = round(rand(n,1)*(numel(image.y_img)-1))+1;
zsamp = diag(image.z_img(xsamp, ysamp));

%start the fitting
f = fit([xsamp, ysamp], zsamp, 'poly11'); % do a fit for a plane
[Y,X] = meshgrid(1:numel(image.y_img), 1:numel(image.x_img));
plane = f.p00 + f.p10*X + f.p01*Y;
topo = imsubtract(image.z_img,plane); % new topography image

% plot the process if necessary
if plot == 1
    figure;
    subplot(1,3,1)
    imagesc(image.z_img'); axis image; axis xy;
    title('Raw Topography')
    subplot(1,3,2)
    imagesc(plane'); axis image; axis xy;
    title('Fitted Plane')
    subplot(1,3,3)
    imagesc(topo'); axis image; axis xy;
    title('Plane Subtracted Topography')
    colormap(gray);
end


end
