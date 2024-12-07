function sliced_grid = gridSliceViewer(data, EnergyLayer, rangeType, colormapName)
% SLICEVIEWERDEC2 Processes and displays 3D dIdV data with selectable range type, colormap, and coordinate mapping
% Merged version of sliceViewer2 and d3gridDisplay by Jiabin Nov 2024
%
% Inputs:
%   data: Raw dIdV data - 3D matrix of scanning tunneling spectroscopy data
%   EnergyLayer: Number of layers - Integer specifying total layers
%   rangeType: Type of range for visualization ('global' or 'dynamic')
%   colormapName: Name of the colormap to use (default is 'invgray')
%
% Output:
%   sliced_grid: 4D matrix containing processed image slices

arguments
    data                (:,:,:) {mustBeNumeric}
    EnergyLayer         (1,1) {mustBeInteger, mustBePositive}
    rangeType           (1,:) char {mustBeMember(rangeType, {'global', 'dynamic'})}
    colormapName        (1,:) char = 'invgray'
end

% Default parameters
if isempty(colormapName)
    colormapName = 'invgray';
end

% Load specified colormap
try
    if strcmp(colormapName, 'invgray')
        load('InverseGray', 'invgray');
        map = invgray;
    else
        % Use MATLAB's built-in colormap
        map = colormap(colormapName);
    end
catch
    % Fallback to default inverse gray if colormap loading fails
    warning('Could not load specified colormap. Falling back to invgray.');
    load('InverseGray', 'invgray');
    map = invgray;
end

% Validate EnergyLayer against data size
if EnergyLayer > size(data, 3) + 1
    error('EnergyLayer cannot be larger than the number of layers in the input data plus one');
end

% Pre-allocate Grid array
Grid = zeros(size(data, 1), size(data, 2), EnergyLayer-1);

% Process each layer of the dIdV data
for k = 1:EnergyLayer-1
    Grid(:,:,k) = data(:,:,k);
end

% Transpose and flip to match Cartesian coordinates
Grid = permute(Grid, [2 1 3]);  % Swap x and y dimensions
Grid = flip(Grid, 1);  % Flip vertically to match Cartesian orientation

% Initialize visualization
figure('Name', sprintf('3D Grid View - %s Range, %s Colormap', rangeType, colormapName));

% Determine global min and max values if global range is selected
if strcmp(rangeType, 'global')
    globalMin = min(Grid(:));
    globalMax = max(Grid(:));
end

% Pre-allocate the sliced grid array
sliced_grid = zeros(size(Grid,1), size(Grid,2), size(Grid,3), 3);

% Parameter for dynamic range contrast
nos = 8;

% Convert Grid to image format using the colormap
for k = 1:size(Grid, 3)
    if strcmp(rangeType, 'dynamic')
        MeddIdV = median(median(Grid(:,:,k)));
        Stdv = std(std(Grid(:,:,k)));
        range = [MeddIdV-nos*Stdv MeddIdV+nos*Stdv];
    else
        range = [globalMin globalMax];
    end
    sliced_grid(:,:,k,:) = mat2im(Grid(:,:,k), map, range);
end

% Display the 3D image stack
imshow3D(sliced_grid);
end