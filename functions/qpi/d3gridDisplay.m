function d3gridDisplay(LDoS_noisy, rangeType)
% Displays a 3D dataset using a specified colormap and range type.
%   This function visualizes a 3D dataset by converting each slice to an image 
%   using a colormap and either a global or dynamic range. The processed slices 
%   are then displayed as a 3D image stack.
%
% Arguments:
%   LDoS_noisy  3D array containing the data to be displayed.
%   rangeType   Type of range for visualization ('global' or 'dynamic').
%
% Returns:
%   None. The function displays the 3D dataset as an image stack.
%
% August 2024 - Dong Chen
%
% Example:
%   d3gridDisplay_QPISIM(LDoS_noisy, 'global');
%   This example displays the dataset with a global intensity range across slices.

% Validate and heal input data
validateData(LDoS_noisy);
LDoS_noisy = dataHealing(LDoS_noisy);

% Normalize data to a reasonable range [0,1]
LDoS_noisy = normalizeData(LDoS_noisy);

% Load colormap
load('InverseGray', 'invgray');
map = gray;

% Determine global min and max values if global range is selected
if strcmp(rangeType, 'global')
    globalMin = 0;  % Since we normalized the data
    globalMax = 1;
end

% Preallocate the sliced LDoS array
slicedglob_LDoS = zeros(size(LDoS_noisy, 1), size(LDoS_noisy, 2), size(LDoS_noisy, 3), 3);

% nos number of standard deviations for dynamic range, larger nos more range.
nos = 25;  % Reduced from 8 to handle normalized data better

% Convert LDoS_result to image format using the colormap
for k = 1:size(LDoS_noisy, 3)
    if strcmp(rangeType, 'dynamic')
        validData = LDoS_noisy(:,:,k);
        validData = validData(~isnan(validData) & ~isinf(validData));
        if ~isempty(validData)
            MeddIdV = median(validData(:));
            Stdv = std(validData(:));
            range = [max(0, MeddIdV-nos*Stdv) min(1, MeddIdV+nos*Stdv)];
        else
            range = [0 1];
        end
    else
        range = [globalMin globalMax];
    end
    
    % Get the current slice
    currentSlice = LDoS_noisy(:,:,k);
    
    % Ensure values are within [0,1] range
    currentSlice = min(max(currentSlice, 0), 1);
    
    % Convert to image
    slicedglob_LDoS(:,:,k,:) = mat2im(currentSlice, map, range);
end

% Display the 3D image stack
imshow3D(slicedglob_LDoS);

end

function data = normalizeData(data)
    % Normalize data to [0,1] range
    minVal = min(data(:));
    maxVal = max(data(:));
    
    % Check if range is valid
    if minVal == maxVal
        warning('Data has no variation (constant values)');
        data = zeros(size(data));
    else
        data = (data - minVal) / (maxVal - minVal);
    end
    
    fprintf('Data normalized to range: [0, 1]\n');
end

function data = dataHealing(data)
    % Data healing function to handle anomalies
    
    % Replace Inf values with NaN
    data(isinf(data)) = NaN;
    
    % Replace complex numbers with NaN
    if ~isreal(data)
        data(imag(data) ~= 0) = NaN;
    end
    
    % For each slice, replace NaN values with interpolated values
    for k = 1:size(data, 3)
        slice = data(:,:,k);
        if any(isnan(slice(:)))
            % Get valid values for interpolation
            validValues = slice(~isnan(slice));
            if ~isempty(validValues)
                validMean = mean(validValues, 'all');
                % Replace NaN with the mean of valid values in the slice
                slice(isnan(slice)) = validMean;
            else
                % If entire slice is NaN, set to zero
                slice(:) = 0;
                warning('Slice %d contained all NaN values, set to zero', k);
            end
            data(:,:,k) = slice;
        end
    end
    
    fprintf('Data healing completed.\n');
    % Report final data range
    fprintf('Healed data range: [%g, %g]\n', min(data(:)), max(data(:)));
end

function validateData(data)
    % Input data validation function
    
    % Check for empty or wrong dimensionality
    if isempty(data)
        error('Input data is empty');
    end
    if ndims(data) ~= 3
        error('Input data must be 3-dimensional');
    end
    
    % Check for NaN values
    nanCount = sum(isnan(data(:)));
    if nanCount > 0
        warning('Data contains %d NaN values', nanCount);
    end
    
    % Check for Inf values
    infCount = sum(isinf(data(:)));
    if infCount > 0
        warning('Data contains %d Infinite values', infCount);
    end
    
    % Check for complex numbers
    if ~isreal(data)
        warning('Data contains complex numbers');
    end
    
    % Report data range
    minVal = min(data(:));
    maxVal = max(data(:));
    fprintf('Data range: [%g, %g]\n', minVal, maxVal);
end
