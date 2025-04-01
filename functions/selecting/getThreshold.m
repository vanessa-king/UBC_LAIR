function [Thresh, comment] = getThreshold(data, plot_histograms, n, V_reduced, imageV)
%% Description:
% getThreshold gets the threshold from the height distribution of the topo
% or dIdV intensity of the energy slice from grid
% suggest running topoPlaneSub first when using topo data
%% Input parameters:
    %   data: 2D or 3D data (grid.z_img or topo (output from topoPlaneSub))
    %   plot_histogram(bool): true to plot histograms; false to not plot
    %   V_reduced: reduced vector with bias voltages(see Derivative function in PD01A for definition of V_reduced); this is
    %   an optional input for the case where the "data" has a 3D structure, e.g. didv. 
    %   imageV: this is an optional input for the case where the "data" has a 3D structure, e.g. didv.      
%% Output parameters:
    %   Thresh(structure): structure containing threshold and masks

arguments
    data        {mustBeNumeric}         % 2D/3D data, topo img or dIdV
    plot_histograms
    n           {mustBePositive} = []   % optional, only for 3D data
    V_reduced   {mustBeNumeric} = []    % optional, only for 3D data
    imageV      {mustBeNumeric} = []    % optional, only for 3D data
end

% Check if data is 2D or 3D
[data_slice, imN, V_actual] = dataSlice2D(data,n,V_reduced,imageV);

% Plot the histogram of the topography to visualize height distribution
if plot_histograms
    hold on
    figure();
    histogram(data_slice)
    title("Height/Intensity distribution")
    xlabel("Height/intensity")
    ylabel("Counts");
    axis square
    hold off
end

%Prompt user for threshold input 
pickManually = input('y for custom threshold, otherwise median threshold: ', 's');
if strcmp(pickManually, 'y')
    [threshold, ~] = ginput(1);
else
    threshold = median(data_slice(:));
end

if plot_histograms
    %Plot the histogram again with the selected threshold marked
    figure("Name", "Height/Intensity Distribution");
    histogram(data_slice);
    title("Height/intensity distribution")
    xlabel("Height/intensity")
    ylabel("Counts");
    axis square
    hold on
    xline(threshold, 'color', [1 0 0])
    hold off
end

%create a threshold image based on the selected threshold

tall_mask = data_slice > threshold;
short_mask = data_slice <= threshold;

% Display the thresholded input data with a colorbar
figure('Name', 'Data_threshold');  %change name of plot
imagesc(data_slice');  %takes transpose of image to plot 
colormap('gray')
colorbar
axis square

% Create a binary contour based on tall and short regions
contour = data_slice;
contour(tall_mask) = 1;
contour(short_mask) = 0;

% Obtain boundary coordinates using a helper function
[boundary_x, boundary_y] = pixelatedContour(contour);
% Plot the boundary on the data figure
hold on
plot(boundary_y,boundary_x,'g','LineWidth',2);axis image; axis xy;
hold off

% define struct for return of function (alternativley return these 5 values
%individually: [threshold, tall_indices, short_indices, boundary_x, boundary_y]
Thresh.threshold = threshold;
Thresh.tall_mask = tall_mask;
Thresh.short_mask = short_mask;
Thresh.boundary_x = boundary_x;
Thresh.boundary_y = boundary_y;

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Never plot data (e.g. the whole gird) in the comment, only plot the values
%('=<VARn_value>') of variables that decide/affect how the function
%processes data (e.g. order of fit, ...) 
%Note convert all <VARn_value> to strings;
comment = sprintf("getThreshold(Image), output: threshold = %.4e|", threshold);

end