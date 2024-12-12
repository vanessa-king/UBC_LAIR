function [M2,idx] = combineMasks(M1, bin_size, bin_sep, omit_incomplete)
%COMBINEMASKS Combine 3D mask array into binned mask array
%
% Arguments:
%   M1              3D logical array (Image_x, Image_y, num_lines)
%   bin_size        Number of slices to combine per bin
%   bin_sep         Separation between start of each bin
%   omit_incomplete Optional. If true, omit incomplete last bin (default: false)
%
% Returns:
%   M2              3D logical array (Image_x, Image_y, num_bins)
%
% Example:
%   M2 = combineMasks(M1, 3, 2, true)  % Overlapping bins, skip incomplete
%   M2 = combineMasks(M1, 3, 4)        % Non-overlapping bins with gap
%
% Notes:
%   - bin_size must be <= number of slices in M1
%   - bin_sep can be < bin_size (overlap) or > bin_size (gap)
%   - Last bin might be incomplete unless omit_incomplete is true
%   - Warning is issued when incomplete bin is included
%
% August 2024 - Dong Chen

% Input validation
assert(ndims(M1) == 3, 'Input mask must be 3D array');
assert(size(M1,3) > 1, 'Input mask must have multiple slices');
assert(islogical(M1), 'Input mask must be logical array');
assert(bin_size > 0 && bin_size <= size(M1,3), ...
    'bin_size must be positive and <= number of slices');
assert(bin_sep > 0, 'bin_sep must be positive');

if nargin < 4
    omit_incomplete = true;
end

% Calculate number of complete bins
num_slices = size(M1,3);
num_complete_bins = floor((num_slices - bin_size) / bin_sep) + 1;

% Create index array for complete bins
idx = zeros(bin_size, num_complete_bins);
for i = 1:num_complete_bins
    start = (i-1)*bin_sep + 1;
    idx(:,i) = start:(start+bin_size-1);
end

% Check for incomplete last bin
remaining_start = (num_complete_bins*bin_sep) + 1;
if remaining_start <= num_slices && ~omit_incomplete
    remaining_size = num_slices - remaining_start + 1;
    if remaining_size > 0
        warning(['Last bin will be incomplete with only ' ...
            num2str(remaining_size) ' slices instead of ' ...
            num2str(bin_size) ' slices']);
        
        % Add indices for incomplete bin
        last_idx = zeros(bin_size, 1);
        last_idx(1:remaining_size) = remaining_start:num_slices;
        idx = cat(3, idx, last_idx);
    end
end

% Initialize output array
M2 = false(size(M1,1), size(M1,2), size(idx,2));

% Combine masks using indices
for i = 1:size(idx,2)
    valid_idx = idx(:,i);
    valid_idx = valid_idx(valid_idx > 0);  % Remove zero padding from incomplete bin
    M2(:,:,i) = any(M1(:,:,valid_idx), 3);
end

end 