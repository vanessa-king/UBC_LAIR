function [corrected_data, streak_mask, streak_indices] = interpolateLocalStreaks3D(Y, slice_idx, min_value, provided_streak_indices)
%INTERPOLATELOCALSTREAKS3D Wrapper function for 3D streak removal and interpolation
%   [corrected_data, streak_mask, streak_indices] = interpolateLocalStreaks3D(Y, slice_idx, min_value, provided_streak_indices)
%   processes 3D data Y by first detecting streaks in a reference slice, then applying
%   the same streak removal to all slices
%
%   Inputs:
%       Y - 3D data array
%       slice_idx - Optional index of the reference slice. If not provided, will display
%                  the dataset for slice selection
%       min_value - Optional minimum value for streak detection (default: interactive)
%       provided_streak_indices - Optional Nx2 array of [row,col] indices for streak points.
%                               If provided, skips interactive detection and applies these indices
%
%   Outputs:
%       corrected_data - The corrected 3D image data
%       streak_mask - Binary mask indicating detected streaks
%       streak_indices - Nx2 array of [row,col] indices for streak points
%
%   Example:
%       % Interactive mode with slice selection
%       [corrected, mask, indices] = interpolateLocalStreaks3D(Y);
%       
%       % Interactive mode with specific slice
%       [corrected, mask, indices] = interpolateLocalStreaks3D(Y, 150);
%       
%       % Non-interactive mode with provided indices
%       [corrected, mask] = interpolateLocalStreaks3D(Y, [], [], provided_indices);

% Input validation
if ~isnumeric(Y) || ndims(Y) ~= 3
    error('Input Y must be a 3D numeric array');
end

% If streak indices are provided, directly apply to all slices
if nargin >= 4 && ~isempty(provided_streak_indices)
    corrected_data = zeros(size(Y), 'single');
    streak_mask = false(size(Y));
    streak_indices = provided_streak_indices;
    
    % Process each slice with progress feedback
    for s = 1:size(Y,3)
        if mod(s,10) == 0
            fprintf('Processing slice %d/%d\n', s, size(Y,3));
        end
        [corrected_data(:,:,s), streak_mask(:,:,s)] = interpolateLocalStreaks(Y, s, [], streak_indices);
    end
    return;
end

% If no slice index provided, show 3D display for selection
if nargin < 2 || isempty(slice_idx)
    figure;
    d3gridDisplay(Y, 'dynamic');
    while true
        slice_idx = input('Enter reference slice number for streak detection: ');
        if isnumeric(slice_idx) && isscalar(slice_idx) && ...
           slice_idx >= 1 && slice_idx <= size(Y,3)
            break;
        end
        disp(['Invalid slice number. Please enter a number between 1 and ' num2str(size(Y,3))]);
    end
    close;
end

% Validate slice_idx
if ~isnumeric(slice_idx) || ~isscalar(slice_idx) || ...
   slice_idx < 1 || slice_idx > size(Y,3)
    error('Invalid slice_idx. Must be a number between 1 and %d', size(Y,3));
end

% Get streak indices from reference slice
[~, ~, streak_indices] = interpolateLocalStreaks(Y, slice_idx, min_value);

% Apply streak removal to all slices
corrected_data = zeros(size(Y));
streak_mask = false(size(Y));

% Process each slice with progress feedback
for s = 1:size(Y,3)
    if mod(s,10) == 0
        fprintf('Processing slice %d/%d\n', s, size(Y,3));
    end
    [corrected_data(:,:,s), streak_mask(:,:,s)] = interpolateLocalStreaks(Y, s, [], streak_indices);
end

end 