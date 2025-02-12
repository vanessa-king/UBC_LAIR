function [topoThresh, comment] = topoGetThreshold(topo, plot_histograms)
%% Description:
% topoGetThreshold gets the threshold from the height distribution of the topo
% suggest running topoPlaneSub first
%% Input parameters:
    % topo(matrix): topo (grid.z_img or topo (output from topoPlaneSub))
    % plot_histogram(bool): true to plot histograms; false to not plot
%% Output parameters:
    % topoThresh(structure): structure containing height_threshold and
    % masks

% Plot the histogram of the topography to visualize height distribution
if plot_histograms
    hold on
    figure();
    histogram(topo)
    title("Topo height distribution")
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
    height_threshold = median(topo(:));
end

if plot_histograms
    %Plot the histogram again with the selected threshold marked
    figure("Name", "Height Distribution");
    histogram(topo);
    title("Topo height distribution")
    xlabel("Height (units?)")
    ylabel("Counts");
    axis square
    hold on
    xline(height_threshold, 'color', [1 0 0])
    hold off
end

%create a threshold image based on the selected threshold

tall_mask = topo > height_threshold;
short_mask = topo <= height_threshold;

% Display the thresholded topography with a colorbar
figure('Name', 'Topography');  %change name of plot
imagesc(topo');  %takes transpose of image to plot 
colormap('gray')
colorbar
axis square

% Create a binary contour based on tall and short regions
contour = topo;
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
topoThresh.height_threshold = height_threshold;
topoThresh.tall_mask = tall_mask;
topoThresh.short_mask = short_mask;
topoThresh.boundary_x = boundary_x;
topoThresh.boundary_y = boundary_y;

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Never plot data (e.g. the whole gird) in the comment, only plot the values
%('=<VARn_value>') of variables that decide/affect how the function
%processes data (e.g. order of fit, ...) 
%Note convert all <VARn_value> to strings;
comment = sprintf("topoGetThreshold(Image), output: height_threshold = %.13f|", height_threshold);

end

