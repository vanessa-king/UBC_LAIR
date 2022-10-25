%creates a window where spectra from points you click are displayed
function [spectra] = clickforspectrum(IVdata,V,imV,n,offset)
%----Inputs----
%IVdata: 3D Matrix with data
%V: Vector with bias voltages
%imV: Voltage at which to display image
%n: Number of point spectra to plot

smoothing = 2; %standard deviation (pixels) of the Gaussian filter for spatial smoothing of data
smoothv = 2; %standard deviation (data points) for Gaussian filtering in V

Vred = V(1:size(IVdata,1));
if smoothing %convolves each image with a Gaussian filter
    flt = fspecial('gaussian',ceil(smoothing*5),smoothing);
    for k = 1:size(IVdata,1)
        IVdata(k,:,:) = imfilter(squeeze(IVdata(k,:,:)),flt,'replicate');
    end
end

[~,imN] = min(abs(Vred-imV));

% if Vred(length(Vred) > Vred(1)) %finds the image you want to display
%     imN = find(Vred>imV,1);
% else
%     imN = find(Vred<imV,1);
% end

IVdata2 = flipdim(permute(IVdata,[1 3 2]),2);

img = figure ('Name', ['Image of states at ',num2str(imV),' V']);imagesc(squeeze(IVdata2(imN,:,:)));colormap('gray');hold on
axis image
spec = figure ('Name', 'Normalized dI/dV at different points'); hold on;xlabel('Bias /V');ylabel('Norm. dI/dV /arb.u.')

R = 2; %defining circles that will be drawn in image
xx = -R:.01:R;
yy = sqrt(R^2-xx.^2);

spectra = zeros(length(Vred),n);

colours = 'rgbcmyk';
for k = 1:n
    figure(img)
    pos = round(ginput(1)); %click where you want the spectrum
    plot(pos(1)+xx,pos(2)+yy,colours(mod(k-1,7)+1))
    plot(pos(1)+xx,pos(2)-yy,colours(mod(k-1,7)+1))
    
    figure(spec)
    spectraraw = squeeze(IVdata2(:,pos(2),pos(1)));
    if smoothv
        spectra(:,k) = Gauss1d(spectraraw,smoothv);
    else
        spectra(:,k) = spectraraw;
    end
    plot(Vred,squeeze(spectra(:,k))+(k-1)*offset,colours(mod(k-1,7)+1),'LineWidth',2)
    %plot(Vred,squeeze(spectra(:,k))+(k-1)*offset)%,'LineWidth',2)
end
