function [comment] = gridClickForSpectrum(didv, V_reduced, imageV, n, offset)
%creates a GUI window where you can select a point(s), then it plots the spectra from that point(s). 
%   
%Arguments:
%   didv:       3D Matrix with dI/dV data in the format: (x,y,V) 
%   V_reduced:  reduced vector with bias voltages (see gridCorrNorm for definition of V_reduced)
%   imageV:     float, Voltage at which to display image
%   n:          integer, Number of point spectra to plot
%   offset:     Vertical offset for each point spectra 

arguments
    didv        {mustBeNumeric}
    V_reduced   {mustBeVector}
    imageV      {mustBeNumeric}
    n           {mustBeNumericOrLogical}
    offset      {mustBeNumeric}
end

%logComment
formatSpec = "gridClickForSpectrum(<dataIn>, <VaxIn>, imageV=%d, n=%d, offset=%d)|";
comment = sprintf(formatSpec, imageV, n, offset);

%regular function processing:

%2D image 'topography image' to be plotted based on the imageV parsed
[~,imN] = min(abs(V_reduced-imageV)); %imN is the index of the dIdV slice to be displayed
fig_plot = didv(:,:,imN); 

%Plotting: TBD use setGraphLayout()
%first plot: img, the grid for you to click on
fig_name = ['dI/dV slice at ',num2str(imageV),' V'];
img = figure('Name', fig_name); 
imagesc(fig_plot); 
colormap('gray'); 
hold on;
axis xy; 
axis image;

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
    position = round(ginputAllPlatform(1)); %click where you want the spectrum
    plot(position(1)+xx,position(2)+yy,colours(mod(k-1,7)+1))
    plot(position(1)+xx,position(2)-yy,colours(mod(k-1,7)+1))
   
    figure(spec)
    plot(V_reduced,squeeze(didv(position(1),position(2),:))+(k-1)*offset,colours(mod(k-1,7)+1))
end
