function [topoThresh, comment] = topoGetThreshold(topo)
%% Description:
% topoGetThreshold gets the threshold from the height distribution of the topo
% suggest running topoPlaneSub first
%% Input parameters:
    % topo(matrix): topo (grid.z_img or topo (output from topoPlaneSub))
%% Output parameters:
    % topoThresh(structure): structure containing height_threshold and
    % masks

% Plot the histogram of the topography to visualize height distribution
hold on
figure();
histogram(topo)
title("Topo height distribution")
xlabel("Height (m)")
ylabel("Counts");
axis square
hold off

%Prompt user for threshold input 
pickManually = input('y for custom threshold, otherwise median threshold [m]: ', 's');
if strcmp(pickManually, 'y')
    [height_threshold, ~] = ginput(1);
else
    height_threshold = median(topo(:));
end

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

%create a threshold image based on the selected threshold
z_img = flip(permute(topo,[2 1]),1);
fig_plot = imresize(z_img, [57, 57]);

tall_mask = fig_plot > height_threshold;
short_mask = fig_plot <= height_threshold;

% Display the thresholded topography with a colorbar
figure('Name', 'Topology');  %change name of plot
imagesc(fig_plot);
colormap('gray')
colorbar
axis square

% Create a binary contour based on tall and short regions
contour = fig_plot;
contour(tall_mask) = 1;
contour(short_mask) = 0;

% Obtain boundary coordinates using a helper function
[boundary_x, boundary_y] = pixelatedContour(contour);
% Plot the boundary on the topography figure
hold on
plot(boundary_x,boundary_y,'g','LineWidth',2);
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

