% Description :  
% what does the function do : Subtracts the plane in topography images, local flat/global flat
% Parameters
%%  Input parameters: 
    % image(structure): the structure variable, either from loadDataUpward or from TopoLoadData
    % n(integer): number of points to sample, the default number is 200 
    % plot(boolean): choose to plot the process of plane sub, the is default is F 
%%  Output parameters: 
    % topo: Outputs a single z matrix with the plane subtracted.


function topo = topoPlaneSub(image,n,plot)

% select mode of operation
if nargin == 1
    n = 200; plot = 0;
elseif nargin == 2
    plot = 0;
end
    
% subtract a plane
xsample = round(rand(n,1)*(numel(image.x_img)-1))+1;
ysample = round(rand(n,1)*(numel(image.y_img)-1))+1;
zsample = diag(image.z_img(xsample, ysample));

%start the fitting
f = fit([xsample, ysample], zsample, 'poly11'); % do a fit for a plane, poly11 is for 2D 1st order polynomial 
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
