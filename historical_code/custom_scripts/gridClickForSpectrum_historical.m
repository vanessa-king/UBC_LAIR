%creates a window where spectra from points you click are displayed
function [] = gridClickForSpectrum(didv,Vred,imV,n,offset,xysmooth, vsmooth, grd)
%----Inputs----
%IVdata: 3D Matrix with data
%V: Vector with bias voltages
%imV: Voltage at which to display image
%n: Number of point spectra to plot
%offset: Vertical offset for each point spectra
%xysmooth: Gaussian smooth std for xy pixels (0 is no smoothing)
%vsmooth: Gaussian smooth std for voltage sweep points (0 is no smoothing)


% smooth data if prompted
if xysmooth
    didv = smoothdata(didv, 2, 'gaussian', xysmooth);
    didv = smoothdata(didv, 3, 'gaussian', xysmooth);
end
if vsmooth
    didv = smoothdata(didv, 1, 'gaussian', vsmooth);
end

% rearrange data 
didv_flip = flip(permute(didv,[1 3 2]),2); % flip didv so that image (x,y) = (0,0) at the bottom left

% use cases for different function arguments
switch nargin
    case 8 % grd data is provided, use the topology instead
        topo = topoPlaneSub(grd,200,0); % subtract plane
        fig_name = 'Topology associated with grid';
        z_img = flip(permute(topo,[2 1]),1);
        fig_plot = imresize(z_img, [size(didv_flip,2), size(didv_flip,3)]);
    case 7 % grd data not provided, use the didv slice at imV
        fig_name = ['Image of states at ',num2str(imV),' V'];
        [~,imN] = min(abs(Vred-imV));
        fig_plot = squeeze(didv_flip(imN,:,:));
end
        

img = figure('Name', fig_name); imagesc(fig_plot); colormap('gray'); hold on
axis image 
spec = figure('Name', 'dI/dV at different points'); hold on; 
xlabel('Bias [V]'); ylabel('dI/dV a.u.')

R = 2; %defining circles that will be drawn in image
xx = -R:.01:R;
yy = sqrt(R^2-xx.^2);

colours = 'rgbcmyk'; % seven colors
for k = 1:n
    figure(img)
    pos = round(ginput(1)); %click where you want the spectrum
    plot(pos(1)+xx,pos(2)+yy,colours(mod(k-1,7)+1))
    plot(pos(1)+xx,pos(2)-yy,colours(mod(k-1,7)+1))
    
    figure(spec)
    plot(Vred,squeeze(didv_flip(:,pos(2),pos(1)))+(k-1)*offset,colours(mod(k-1,7)+1))
end
