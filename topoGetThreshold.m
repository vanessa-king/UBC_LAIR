function [height_threshold, tall_indices, short_indices, boundary_x, boundary_y] = topoGetThreshold(topo)
%topoGetThreshold Gets the threshold from the height distribution
%of the topo

histogram(topo);
title("Topo height distribution")
xlabel("Height (units?)")
ylabel("Counts");
axis square

pickManually = input('y for custom threshold, otherwise median threshold: ', 's');
if strcmp(pickManually, 'y')
    [height_threshold, ~] = ginput(1);
else
    height_threshold = median(topo(:));
end

figure();
histogram(topo);
title("Topo height distribution")
xlabel("Height (units?)")
ylabel("Counts");
axis square
hold on
xline(height_threshold, 'color', [1 0 0])
hold off

z_img = flip(permute(topo,[2 1]),1);
fig_plot = imresize(z_img, [57, 57]);

tall_indices = fig_plot > height_threshold;
short_indices = fig_plot <= height_threshold;

figure('Name', 'Topology');
imagesc(fig_plot);
colormap('gray')
colorbar
axis square

contour = fig_plot;
contour(tall_indices) = 1;
contour(short_indices) = 0;

[boundary_x, boundary_y] = pixelatedContour(contour);
hold on
plot(boundary_x,boundary_y,'g','LineWidth',2);
hold off

end