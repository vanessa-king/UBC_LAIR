function [Thresh, comment] = GetThreshold(data, plot_histograms, V_reduced, imageV)
%% Description:
% GetThreshold gets the threshold from the height distribution of the topo
% or E slice from grid
% suggest running topoPlaneSub first
%% Input parameters:
    %   data(matrix): data (grid.z_img or topo (output from topoPlaneSub))
    %   plot_histogram(bool): true to plot histograms; false to not plot
    %   V_reduced: reduced vector with bias voltages(see Derivative function in PD01A for definition of V_reduced); this is
    %   imageV: this is an optional input for the case where the "data" has a 3D structure, e.g. didv. 
    %   an optional input for the case where the "data" has a 3D structure, e.g. didv. 
%% Output parameters:
    %   Thresh(structure): structure containing height_threshold and
    %   masks

arguments
    data
    plot_histograms
    V_reduced        = []     % optional, only for 3D data
    imageV           = []     %optional only for 3D data
end

% Check if data is 2D or 3D
dimData = ndims(data);

if dimData == 3
    % Ensure V_reduced and imageV are provided for 3D data
    if isempty(V_reduced) || isempty(imageV)
        error('For 3D data, both V_reduced and imageV are required inputs.');
    end
    % Select the energy slice for processing
    [~,imN] = min(abs(V_reduced-imageV));
    data_slice = data(:,:,imN); % Extract the closest slice

else
    if dimData ~= 2
        error('Data must be either 2D or 3D.');
    end
    data_slice = data;  % Use data directly for 2D case
end

% Plot the histogram of the topography to visualize height distribution
if plot_histograms
    hold on
    figure();
    histogram(data_slice)
    title("height distribution")
    xlabel("Height (m)")
    ylabel("Counts");
    axis square
    hold off
end

%Prompt user for threshold input 
pickManually = input('y for custom threshold, otherwise median threshold [m]: ', 's');
if strcmp(pickManually, 'y')
    [height_threshold, ~] = ginput(1);
else
    height_threshold = median(data_slice(:));
end

if plot_histograms
    %Plot the histogram again with the selected threshold marked
    figure("Name", "Height Distribution");
    histogram(data_slice);
    title("height distribution")
    xlabel("Height (units?)")
    ylabel("Counts");
    axis square
    hold on
    xline(height_threshold, 'color', [1 0 0])
    hold off
end

%create a threshold image based on the selected threshold

tall_mask = data_slice > height_threshold;
short_mask = data_slice <= height_threshold;

% Display the thresholded topography with a colorbar
figure('Name', 'Topography');  %change name of plot
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
% Plot the boundary on the topography figure
hold on
plot(boundary_y,boundary_x,'g','LineWidth',2);axis image; axis xy;
hold off

% define struct for return of function (alternativley return these 5 values
%individually: [height_threshold, tall_indices, short_indices, boundary_x, boundary_y]
Thresh.height_threshold = height_threshold;
Thresh.tall_mask = tall_mask;
Thresh.short_mask = short_mask;
Thresh.boundary_x = boundary_x;
Thresh.boundary_y = boundary_y;

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Never plot data (e.g. the whole gird) in the comment, only plot the values
%('=<VARn_value>') of variables that decide/affect how the function
%processes data (e.g. order of fit, ...) 
%Note convert all <VARn_value> to strings;
comment = sprintf("GetThreshold(Image), output: height_threshold = %.13f|", height_threshold);

end

