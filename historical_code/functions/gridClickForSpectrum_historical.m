function [comment] = gridClickForSpectrum_historical(didv, V_reduced, imageV, offset, n, pointsList)
%creates a GUI window where you can select a point(s), then it plots the spectra from that point(s). 
%   Plots a 2D slice of the didv data at the closest value of V_reduced to 
%   the set value imageV. From this figure up to n points can be selected 
%   by clicking on the 2D image. For the selected points the spectra didv(V) 
%   are plotted. 
%
% Edited: M. Altthaler 05/2024; Vanessa 2023
%
%   OPT TBD:    make function accept a list of point coordinates to be
%               plotted. This feature is untested! (05/2024)
%
%Arguments:
%   didv:       3D Matrix with dI/dV data in the format: (x,y,V) 
%   V_reduced:  reduced vector with bias voltages (see gridCorrNorm for definition of V_reduced)
%   imageV:     float, Voltage at which to display image
%   offset:     Vertical offset for each point spectra 
%   n:          integer, Number of point spectra to plot (optional, default: 2)
%   pointsList: list of (x,y) coordinates in nx2 format (optional, default: [])

arguments
    didv        {mustBeNumeric}
    V_reduced   {mustBeVector}
    imageV      {mustBeNumeric}
    offset      {mustBeNumeric}=0
    n           {mustBeNumericOrLogical,mustBePositive}=2
    pointsList  {mustBeNumeric}=[]
end

%logComment
formatSpec = "gridClickForSpectrum(<dataIn>, <VaxIn>, imageV=%d, offset=%d, n=%d)|";
comment = sprintf(formatSpec, imageV, offset, n);

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

%second plot: spec, the spectra for the points you clicked on
spec = figure('Name', 'dI/dV at different points'); hold on;
xlabel('Bias [V]'); ylabel('dI/dV a.u.')

%defining the circles that will be drawn on the image
radius = 2; 
xx = -radius:.01:radius;
yy = sqrt(radius^2-xx.^2);

% A list of the colours to be used to represent the different points (up to 7)
%for loop for every point clicked.
colours = 'rgbcmyk'; 

%init append (x,y) coordinates to the comment
commentAppend = 'selected points (x,y): ';
comment = strcat(comment,commentAppend);


if isempty(pointsList)
    %click for points
    for k = 1:n
        figure(img)
        position = round(ginputAllPlatform(1)); %click where you want the spectrum
        plot(position(1)+xx,position(2)+yy,colours(mod(k-1,7)+1))
        plot(position(1)+xx,position(2)-yy,colours(mod(k-1,7)+1))
        
        %appends clicked position to the log comment
        commentAppend = sprintf('(%d,%d), ',position(1),position(2));
        comment = strcat(comment,commentAppend);
       
        figure(spec)
        plot(V_reduced,squeeze(didv(position(1),position(2),:))+(k-1)*offset,colours(mod(k-1,7)+1))
    end
else
    %plot pointsList
    for k = 1:length(pointsList)
        figure(img)
        position = pointsList(k,:); %assing k-th point of the list to position instead of klicking
        plot(position(1)+xx,position(2)+yy,colours(mod(k-1,7)+1))
        plot(position(1)+xx,position(2)-yy,colours(mod(k-1,7)+1))
        
        %appends clicked position to the log comment
        commentAppend = sprintf('(%d,%d), ',position(1),position(2));
        comment = strcat(comment,commentAppend);
       
        figure(spec)
        plot(V_reduced,squeeze(didv(position(1),position(2),:))+(k-1)*offset,colours(mod(k-1,7)+1))
    end
end
