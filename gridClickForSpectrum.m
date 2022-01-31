
function [] = gridClickForSpectrum(didv, V_reduced, imageV, n, offset, xysmooth, vsmooth, grd)
%Description:   
%   creates a GUI window where you can select a point(s), then it plots the spectra from that point(s).
%Parameters:
%   didv: 3D Matrix with dI/dV data
%   V_reduced: reduced vector with bias voltages (see gridCorrNorm for definition of V_reduced)
%   imageV: float, Voltage at which to display image
%   n: integer, Number of point spectra to plot
%   offset: Vertical offset for each point spectra 
%   xysmooth: float, the standard deviation of a Gaussian for smoothing xy pixels (0 is no smoothing)
%   vsmooth: float, the standard deviation of a Gaussian for smoothing the voltage sweep points (0 is no smoothing)
%   grd: 1*1 structure, output from gridLoadData, optional


% smooth data if prompted
if xysmooth %then smooth along axes 2 and 3 which correspond to x and y
    didv = smoothdata(didv, 2, 'gaussian', xysmooth);
    didv = smoothdata(didv, 3, 'gaussian', xysmooth);
end
if vsmooth %then smooth along axes 1 which correspond to bias voltage
    didv = smoothdata(didv, 1, 'gaussian', vsmooth);
end

% rearrange data
didv_flip = flip(permute(didv,[1 3 2]),2); % flip didv so that image (x,y) = (0,0) at the bottom left

% use cases for different function arguments -> use dIdV at imageV, or use the topo
switch nargin
    case 8 % grd data is provided, use the topology instead
        topo = topoPlaneSub(grd,200,0); % subtract plane
        fig_name = 'Topology associated with grid';
        z_img = flip(permute(topo,[2 1]),1);
        fig_plot = imresize(z_img, [size(didv_flip,2), size(didv_flip,3)]);
    case 7 % grd data not provided, use the didv slice at imageV
        fig_name = ['Image of states at ',num2str(imageV),' V'];
        [~,imN] = min(abs(V_reduced-imageV));
        fig_plot = squeeze(didv_flip(imN,:,:));
end
       
%Plotting:
%first plot: img, the grid for you to click on
img = figure('Name', fig_name); imagesc(fig_plot); colormap('gray'); hold on
axis image
%second plot: spec, the spectra fo the points you clicked on
spec = figure('Name', 'dI/dV at different points'); hold on;
xlabel('Bias [V]'); ylabel('dI/dV a.u.')

%defining the circles that will be drawn on the image
radius = 2; 
xx = -radius:.01:radius;
yy = sqrt(radius^2-xx.^2);

colours = 'rgbcmyk'; % A list of the colours to be used to represent the different points (up to 7)
%for loop for every point clicked.
for k = 1:n
    figure(img)
    position = round(ginput(1)); %click where you want the spectrum
    plot(position(1)+xx,position(2)+yy,colours(mod(k-1,7)+1))
    plot(position(1)+xx,position(2)-yy,colours(mod(k-1,7)+1))
   
    figure(spec)
    plot(V_reduced,squeeze(didv_flip(:,position(2),position(1)))+(k-1)*offset,colours(mod(k-1,7)+1))
end
