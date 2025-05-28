function [sliced_grid, sliceNumbers, voltages] = gridSliceViewer(data, V, rangeType, colormapName, dataset, LOGpath, LOGfile)
% GRIDSLICEVIEWER Processes 3D dIdV data into an RGB image stack for visualization.
%   Edited by Jiabin Nov 2024, James May 2025
%
% Inputs:
%   data: 3D matrix (x, y, V) of dIdV data.
%   V: Voltage vector (column) matching data's third dimension.
%   rangeType: 'global' or 'dynamic'.
%   colormapName: Colormap name (default 'invgray').
%   LOGpath: Path to log file (for capture logging).
%   LOGfile: Log file name (for capture logging).
%
% Outputs:
%   sliced_grid: 4D RGB stack (x, y, slices, 3).
%   voltages: Corresponding voltages from V as column.

arguments
    data (:,:,:) {mustBeNumeric}
    V (:,1) {mustBeNumeric}
    rangeType (1,:) char {mustBeMember(rangeType, {'global', 'dynamic'})}
    colormapName (1,:) char = 'invgray'
    dataset (1,:) char = 'grid'
    LOGpath (1,:) char = ''
    LOGfile (1,:) char = ''
end

% Validate inputs
if size(data, 3) ~= length(V)
    error('Length of V (%d) must match third dimension of data (%d)', length(V), size(data, 3));
end

% Load colormap
if strcmp(colormapName, 'invgray')
    load('InverseGray', 'invgray');
    map = invgray;
else
    try
        map = colormap(colormapName);
    catch
        warning('Invalid colormap "%s". Using invgray.', colormapName);
        load('InverseGray', 'invgray');
        map = invgray;
    end
end

% Prepare data
Grid = permute(data, [2 1 3]);
Grid = flip(Grid, 1);

% Set range
if strcmp(rangeType, 'global')
    globalMin = min(Grid(:));
    globalMax = max(Grid(:));
end

% Pre-allocate output
sliced_grid = zeros(size(Grid, 1), size(Grid, 2), size(data, 3), 3);
sliceNumbers = (1:size(data, 3))';
voltages = V(1:size(data, 3));

% Process slices
for k = 1:size(data, 3)
    sliceData = Grid(:,:,k);
    if strcmp(rangeType, 'dynamic')
        med = median(sliceData(:));
        stdv = std(sliceData(:));
        range = [med - 8*stdv, med + 8*stdv];
    else
        range = [globalMin, globalMax];
    end
    sliced_grid(:,:,k,:) = mat2im(sliceData, map, range);
end

% Display
figure('Name', sprintf('3D Grid View - %s Range, %s Colormap', rangeType, colormapName));
imshow3D_LAIR(sliced_grid, [], voltages, dataset, LOGpath, LOGfile);

    % Nested mat2im
    function im = mat2im(mat, cmap, limits)
        if ~isa(mat, 'double')
            mat = double(mat) + 1;
        end
        if ~isnumeric(cmap)
            error('cmap must be a numeric colormap');
        end
        if nargin < 3
            minVal = min(mat(:));
            maxVal = max(mat(:));
        else
            minVal = limits(1);
            if isnan(minVal), minVal = min(mat(:)); end
            mat(mat < minVal) = minVal;
            maxVal = limits(2);
            if isnan(maxVal), maxVal = max(mat(:)); end
            mat(mat > maxVal) = maxVal;
        end
        L = size(cmap, 1);
        mat = mat - minVal;
        mat = (mat / (maxVal - minVal)) * (L - 1);
        mat = mat + 1;
        mat = round(mat);
        im = reshape(cmap(mat(:), :), [size(mat), 3]);
    end
end