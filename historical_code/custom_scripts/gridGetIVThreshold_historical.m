% Description
%   gridGetIVThreshold Thresholds a grid with dI/dV data at a specific bias
%   Two options: custom threshold or through the median value from the dI/dV distribution plot
% Parameters
%   Input:
%   I = number_bias_layer x grid length x grid width data
%   V = V data
%   bias = bias slice to threshold
%   nbins = number of bins
%   Outputs:
%   I_threshold = median I(V) value of slice
%   bright_indices = 1D array of indices of I(V) values above I_threshold.
%   These work for flipped I only.
%   dark_indices = 1D array of indices of I(V) values below or equal to
%   I_threshold. These work for flipped I only.

function [gridIVThresh] = gridGetIVThreshold_historical(I, V, bias, nbins)
 
% load colourmap
color_scale_resolution = 1000; % 1000 evenly spaced colour points
cm_viridis = viridis(color_scale_resolution); % Default matplotlib(for LAIR)
cm_inferno = inferno(color_scale_resolution);
cm_magma = magma(color_scale_resolution);
cm_plasma = plasma(color_scale_resolution);
clims = [1.7E-9,3E-9]; % This is to adjust dI/dV range to see the features on the grid image better. Change as needed.

I = flip(permute(I,[1 3 2]),2);
[~,imN] = min(abs(V-bias));

I_slice = squeeze(I(imN, :, :));

% This plots dI/dV distribution of the grid at a given bias.
figure();
histogram(I_slice, nbins); 
title("dI/dV distribution")
xlabel("dI/dV")
ylabel("Counts");
axis square

pickManually = input('type y for custom threshold, otherwise median threshold: ', 's'); % Type y to manually choose a threshold by clicking on the dI/dV distribution plot
if strcmp(pickManually, 'y')
    [I_threshold, ~] = ginputAllPlatform(1);
else
    I_threshold = median(I_slice(:));
end

figure();
histogram(I_slice, nbins);
title("dI/dV distribution")
xlabel("dI/dV")
ylabel("Counts");
axis square
hold on
xline(I_threshold, 'color', [1 0 0])
hold off

bright_indices = I_slice > I_threshold;
dark_indices = I_slice <= I_threshold;

figure();
imagesc(I_slice, clims);
axis square
title(['Slice at ',num2str(bias),' V']);
colormap(cm_magma)
colorbar

contour = I_slice;
contour(bright_indices) = 1;
contour(dark_indices) = 0;
[boundary_x, boundary_y] = pixelatedContour(contour);
hold on
plot(boundary_x,boundary_y, 'g', 'LineWidth', 2);
hold off

%define struct for return of function (alternativley return these 5 values
%individually: [I_threshold, bright_indices, dark_indices, boundary_x, boundary_y]
gridIVThresh.I_threshold = I_threshold;
gridIVThresh.bright_indices = bright_indices;
gridIVThresh.dark_indices = dark_indices;
gridIVThresh.boundary_x = boundary_x;
gridIVThresh.boundary_y = boundary_y;
end
