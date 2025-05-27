function [normalized_data_3d, background_info, comment] = normalizeBackgroundToZeroMean3D(data_3d, rangeType, selected_slice)
% Normalizes each slice of a 3D dataset by subtracting the mean of a user-selected background area.
%   This function allows the user to interactively select a background region from a slice in a 3D dataset.
%   For every slice, the mean of the selected background area is subtracted from each slice in the 3D dataset, 
%   resulting in a normalized dataset slice wise.
%
% Arguments:
%   data_3d          3D array containing the data to be processed.
%   rangeType        Type of range for visualization ('global' or 'dynamic').
%   selected_slice   (Optional) The index of the slice to use for background selection. 
%                   If empty or not provided, displays full 3D dataset for selection.
%
% Returns:
%   normalized_data_3d   The 3D data array with each slice normalized to the selected background area.
%   background_info      [mean, variance] of the selected background area.
%   comment              Comment for logging the function call.
%
% August 2024 - Dong Chen
%
% Example:
%   [normalized_data_3d, background_info, comment] = normalizeBackgroundToZeroMean3D(data_3d, 'global');
%   [normalized_data_3d, background_info, comment] = normalizeBackgroundToZeroMean3D(data_3d, 'global', []);  % Display full dataset
%   [normalized_data_3d, background_info, comment] = normalizeBackgroundToZeroMean3D(data_3d, 'global', 5);   % Use slice 5

arguments
    data_3d
    rangeType
    selected_slice = []  % Default to empty if not provided
end

% LOG comment of function call
if isempty(selected_slice)
    comment = sprintf("normalizeBackgroundToZeroMean3D(selected_slice:full_dataset)|");
else
    comment = sprintf("normalizeBackgroundToZeroMean3D(selected_slice:%d)|", selected_slice);
end

% Get the dimensions of the 3D data array
[rows, cols, k] = size(data_3d);

% Display the data and get slice selection if needed
if isempty(selected_slice)
    % Display full 3D dataset
    figure;
    d3gridDisplay(data_3d, rangeType);
    selected_slice = input('Enter the slice number to select background: ');
    if isempty(selected_slice) || selected_slice < 1 || selected_slice > k
        error('Invalid slice number');
    end
    close;  % Close the d3gridDisplay figure
end

% Display the selected slice and allow the user to select a rectangular region
figure;
imagesc(data_3d(:,:,selected_slice));
%colormap('viridis');
axis square;
title('Select Background Area (This will be applied to all slices)');
h = imrect;
position = wait(h);  % Wait for the user to double-click the rectangle
close;  % Close the figure after selection

% Get the coordinates of the selected rectangle
x_min = round(position(1));
y_min = round(position(2));
x_max = round(position(1) + position(3));
y_max = round(position(2) + position(4));

% Initialize the output array with correct dimensions
normalized_data_3d = zeros(size(data_3d));  % Use exact same size as input

% Process each slice individually using the same background area
for i = 1:k
    background = data_3d(y_min:y_max, x_min:x_max, i);
    background_mean = mean(background(:));
    background_info = [background_mean, var(background(:))];
    
    % Extract the current slice
    data = data_3d(:, :, i);
    
    % Normalize the entire data slice by subtracting the background mean
    normalized_data = data - background_mean;
    
    % Store the normalized slice back into the 3D array
    normalized_data_3d(:, :, i) = normalized_data;
end
end
