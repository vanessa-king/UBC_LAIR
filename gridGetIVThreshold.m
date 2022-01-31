% Description
%   gridGetIVThreshold Thresholds a grid with IV data at a specific bias
%   Two options: custom threshold or through the median value from the dIdV distribution plot
% Parameters
%   iv_data = V x grid length x grid width data
%   V = V data
%   bias = bias slice to threshold
%   iv_threshold = median iv value of slice
%   bright_indices = 1D array of indices of iv values above threshold.
%   These work for flipped iv_data only.
%   dark_indices = 1D array of indices of iv values below or equal to
%   threshold. These work for flipped iv_data only.

function [iv_threshold, bright_indices, dark_indices, boundary_x, boundary_y] = gridGetIVThreshold(iv_data, V, bias)

% load colourmap
color_scale_resolution = 1000; % 1000 evenly spaced colour points
cm_viridis = viridis(color_scale_resolution); % Default matplotlib(for LAIR)
cm_inferno = inferno(color_scale_resolution);
cm_magma = magma(color_scale_resolution);
cm_plasma = plasma(color_scale_resolution);
clims = [1.7E-9,3E-9]; % This is to adjust dI/dV range to see the features on the grid image better. Change as needed.

iv_data = flip(permute(iv_data,[1 3 2]),2);
[~,imN] = min(abs(V-bias));

iv_slice = squeeze(iv_data(imN, :, :));

figure();
histogram(iv_slice); % This plots dI/dV distribution of the grid at a given bias
title("dI/dV distribution")
xlabel("dI/dV")
ylabel("Counts");
axis square

pickManually = input('type y for custom threshold, otherwise median threshold: ', 's'); % Type y to manually choose a threshold by clicking on the dI/dV distribution plot
if strcmp(pickManually, 'y')
    [iv_threshold, ~] = ginput(1);
else
    iv_threshold = median(iv_slice(:));
end

figure();
histogram(iv_slice);
title("dI/dV distribution")
xlabel("dI/dV")
ylabel("Counts");
axis square
hold on
xline(iv_threshold, 'color', [1 0 0])
hold off

bright_indices = iv_slice > iv_threshold;
dark_indices = iv_slice <= iv_threshold;

figure();
imagesc(iv_slice, clims);
axis square
title(['Slice at ',num2str(bias),' V']);
colormap(cm_magma)
colorbar

contour = iv_slice;
contour(bright_indices) = 1;
contour(dark_indices) = 0;
[boundary_x, boundary_y] = pixelatedContour(contour);
hold on
plot(boundary_x,boundary_y, 'g', 'LineWidth', 2);
hold off
end
