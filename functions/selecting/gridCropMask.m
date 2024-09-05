function [Cropped_data, comment] = gridCropMask(data, mask)
% Crops the input data to the area defined by a logical mask.
%   This function crops the input 2D or 3D data array to the region defined 
%   by a logical mask. The mask must define a rectangular region, and the 
%   function returns an error if the mask is not rectangular.
%
% Arguments:
%   data        2D or 3D array containing the data to be cropped.
%   mask        Logical 2D array specifying the area to crop.
%
% Returns:
%   Cropped_data    The cropped data array.
%   comment         Comment for logging the function call.
%
% August 2024 - Dong Chen
%
% Example:
%   [Cropped_data, comment] = gridCropMask(data, mask);
%   This example crops the input data to the region specified by the mask.

arguments
    data    
    mask logical
end

% Determine the size of data and mask
data_size = size(data);
mask_size = size(mask);

% LOG comment of function call
if ndims(data) == 2
    comment = sprintf("gridCropMask(datasize:%s x %s, mask:%s x %s)|", ...
        mat2str(data_size(1)), mat2str(data_size(2)), ...
        mat2str(mask_size(1)), mat2str(mask_size(2)));
elseif ndims(data) == 3
    comment = sprintf("gridCropMask(datasize:%s x %s x %s, mask:%s x %s)|", ...
        mat2str(data_size(1)), mat2str(data_size(2)), mat2str(data_size(3)), ...
        mat2str(mask_size(1)), mat2str(mask_size(2)));
else
    error('Unsupported data dimensions.');
end

% Find indices of true elements in the mask
[row, col] = find(mask);

% Determine the start and end points of the rectangle
x_start = min(row);
x_end = max(row);
y_start = min(col);
y_end = max(col);

% Check if the mask forms a perfect rectangle
isRectangular = true;
check_mask = false(size(mask));
check_mask(x_start:x_end, y_start:y_end) = true;

if any(check_mask(:) ~= mask(:))
    isRectangular = false;
end

% Return the cropped data if the mask is rectangular, otherwise issue an error
if isRectangular
    if ndims(data) == 2
        Cropped_data = data(x_start:x_end, y_start:y_end);
    elseif ndims(data) == 3
        Cropped_data = data(x_start:x_end, y_start:y_end, :);
    else
        error('Unsupported data dimensions.');
    end
else
    error('The mask is not rectangular. Please use a rectangular mask.');
end

end
