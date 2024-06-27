function [Cropped_data, comment] = gridCropMask(data, mask)
% The data is cropped to the masked area. 

% Validate inputs
arguments
    data    
    mask logical
end

% Determine the size of data
data_size = size(data);
mask_size = size(mask);

% LOG comment of function call
if ndims(data) == 2
    comment = sprintf("gridCropMask(datasize:%s x %s, mask:%s x %s)|", ...
        mat2str(data_size,1), mat2str(data_size,2), ...
        mat2str(mask_size, 1), mat2str(mask_size, 2));
elseif ndims(data) == 3
    comment = sprintf("gridCropMask(datasize:%s x %s x %s, mask:%s x %s)|", ...
        mat2str(data_size,1), mat2str(data_size,2), mat2str(data_size,3), ...
        mat2str(mask_size, 1), mat2str(mask_size, 2));
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
check_mask = zeros(size(mask));
check_mask(x_start:x_end, y_start:y_end) = 1;

if sum(check_mask - mask, "all") ~= 0
    isRectangular = false;
end

% Return the cropped data if the mask is rectangular, otherwise issue a warning
if isRectangular
    if ndims(data) == 2
        Cropped_data = data(x_start:x_end, y_start:y_end);
    elseif ndims(data) == 3
        Cropped_data = data(x_start:x_end, y_start:y_end, :);
    else
        error('Unsupported data dimensions.');
    end
else
    error('Please use a rectangular mask.');
end
end