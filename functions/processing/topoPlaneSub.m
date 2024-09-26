function [z_flat,comment] = topoPlaneSub(x,y,z,n,plot)
% Description :
% Subtracts the plane in topography images, local flat/global flat
% Parameters
%%  Input parameters:
    % x(double): x axis
    % y(double): y axis
    % z(double): topo image
    % n(integer): number of points to sample, the default number is 200
    % plot(boolean): choose to plot the process of plane sub, the is default is F
%%  Output parameters:
    % z_flatten(double): flattened image

arguments
x       {mustBeNumeric}
y       {mustBeNumeric}
z       {mustBeNumeric}
n       {mustBeNumeric}=200
plot    {mustBeNumeric}=0
end

% comment
comment = sprintf("topoPaneSub(x, y, z, n = %s, plot = %s)|", num2str(n), num2str(plot));

% subtract a plane
xsample = round(rand(n,1)*(numel(x)-1))+1;
ysample = round(rand(n,1)*(numel(y)-1))+1;
zsample = diag(z(xsample, ysample));

%start the fitting
f = fit([xsample, ysample], zsample, 'poly11'); % do a fit for a plane, poly11 is for 2D 1st order polynomial
[Y,X] = meshgrid(1:numel(y), 1:numel(x));
plane = f.p00 + f.p10*X + f.p01*Y;
z_flat = imsubtract(z,plane); % new topography image

% plot the process if desired
if plot == 1
    figure;
    subplot(1,3,1)
    imagesc(z'); axis image; axis xy;
    title('Raw Topography')
    subplot(1,3,2)
    imagesc(plane'); axis image; axis xy;
    title('Fitted Plane')
    subplot(1,3,3)
    imagesc(z_flat'); axis image; axis xy;
    title('Plane Subtracted Topography')
    colormap(gray);
end

end









