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
%   grid: 1*1 structure, output from gridLoadData, optional

function [comment] = gridClickForSpectrum(didv, V_reduced, imageV, n, offset, xysmooth, vsmooth, grid)

arguments
    didv          
    V_reduced   {mustBeVector}
    imageV      {mustBeNumeric}
    n           {mustBeNumericOrLogical}
    offset
    xysmooth    {mustBeNumeric}
    vsmooth     {mustBeNumeric}
    grid        =[] %optional input
end

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Never plot data (e.g. the whole grid) in the comment, only plot the values
%('=<VARn_value>') of variables that decide/affect how the function
%processes data (e.g. order of fit, ...) 
%Note convert all <VARn_value> to strings; 
formatSpec = "gridClickForSpectrum(didv: %s, V_reduced: %s, imageV=%s, n=%s, offset=%s, xysmooth=%s, vsmooth=%s, grid: %s)|";
comment = sprintf(formatSpec, mat2str(size(didv)), mat2str(size(V_reduced)), num2str(imageV), num2str(n), num2str(offset), num2str(xysmooth), num2str(vsmooth), mat2str(size(grid)));

%regular function processing:


% smooth data if prompted
if xysmooth %then smooth along axes 2 and 3 which correspond to x and y
    didv = smoothdata(didv, 2, 'gaussian', xysmooth);
    didv = smoothdata(didv, 3, 'gaussian', xysmooth);
end
if vsmooth %then smooth along axes 1 which correspond to bias voltage
    didv = smoothdata(didv, 1, 'gaussian', vsmooth);
end

% use cases for different function arguments -> use dIdV at imageV, or use the topo
if isempty(grid) %if there is no grid use topo image
    fig_name = ['Image of states at ',num2str(imageV),' V'];
    [~,imN] = min(abs(V_reduced-imageV));
    fig_plot = squeeze(didv(imN,:,:));
else %there is a grid, use grid slice
    z_img = topoPlaneSub(grid,200,0); % subtract plane
    fig_name = 'Topology associated with grid';
    fig_plot = imresize(z_img, [size(didv,2), size(didv,3)]);
end
       
%Plotting:
%first plot: img, the grid for you to click on
img = figure('Name', fig_name); imagesc(fig_plot); colormap('gray'); hold on;
axis xy; axis image;
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
    plot(V_reduced,squeeze(didv(:,position(2),position(1)))+(k-1)*offset,colours(mod(k-1,7)+1))
end
