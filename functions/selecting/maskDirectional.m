function [masks, masks_combined, comment] = maskDirectional(data, varargin)
% MASKDIRECTIONAL Create directional masks and combine them
% This function is a wrapper that creates directional masks and optionally
% combines them using specified binning parameters.
%
% Arguments:
%   data            2D or 3D array containing the data
%   varargin        Optional arguments:
%                   - connected: logical flag for side connectivity (default false)
%                   - startPoint: [x1,y1] start point coordinates
%                   - endPoint: [x2,y2] end point coordinates
%                   - bin_size: Number of slices to combine per bin
%                   - bin_sep: Separation between start of each bin
%
% Returns:
%   masks           3D array of original masks (data_dim x data_dim x L)
%   masks_combined  3D array of combined masks (if bin parameters provided)
%                   or empty array (if no bin parameters)
%   comment         String containing function call information
%
% Example:
%   % Just create masks:
%   [masks, ~, comment] = maskDirectional(data)
%   % Create and combine masks:
%   [masks, masks_combined, comment] = maskDirectional(data, 'bin_size', 3, 'bin_sep', 2)
%
% See also: maskSingleDirectional, combineMasks
% Dec 2024 - Dong Chen

% Check if input is 3D
if ndims(data) == 3
    % Display 3D dataset
    fprintf('3D dataset detected. Please select a slice for mask creation.\n');
    gridSliceViewer(data, 1,'dynamic');
    
    % Prompt user for slice selection
    slice_idx = input('Enter the slice number to use: ');
    while isempty(slice_idx) || slice_idx < 1 || slice_idx > size(data, 3)
        fprintf('Invalid slice number. Please enter a number between 1 and %d\n', size(data, 3));
        slice_idx = input('Enter the slice number to use: ');
    end
    
    % Extract the selected slice
    data = data(:,:,slice_idx);
    fprintf('Using slice %d for mask creation\n', slice_idx);
end

% Parse optional inputs
p = inputParser;
addParameter(p, 'connected', false, @islogical);
addParameter(p, 'startPoint', [], @(x) isempty(x) || (isnumeric(x) && numel(x)==2));
addParameter(p, 'endPoint', [], @(x) isempty(x) || (isnumeric(x) && numel(x)==2));
addParameter(p, 'bin_size', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x > 0));
addParameter(p, 'bin_sep', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x > 0));
parse(p, varargin{:});

% Get directional masks
[masks, dir_comment] = maskSingleDirectional(data, p.Results.connected, ...
    p.Results.startPoint, p.Results.endPoint);

% Initialize combined masks as empty
masks_combined = [];
comment = dir_comment;

% Only combine masks if both bin parameters are provided
if ~isempty(p.Results.bin_size) && ~isempty(p.Results.bin_sep)
    [masks_combined, idx] = combineMasks(masks, p.Results.bin_size, p.Results.bin_sep);
    
    % Update comment
    comment = sprintf('%s\nCombined with bin_size=%d, bin_sep=%d', ...
        dir_comment, p.Results.bin_size, p.Results.bin_sep);
    
    % Print combination summary
    fprintf('\nMask Generation Summary:\n');
    fprintf('Original masks: %d x %d x %d\n', size(masks));
    fprintf('Combined masks: %d x %d x %d\n', size(masks_combined));
    fprintf('Binning: size=%d, separation=%d\n', p.Results.bin_size, p.Results.bin_sep);
    if p.Results.bin_sep < p.Results.bin_size
        fprintf('Overlap: %d slices\n', p.Results.bin_size - p.Results.bin_sep);
    elseif p.Results.bin_sep > p.Results.bin_size
        fprintf('Gap: %d slices\n', p.Results.bin_sep - p.Results.bin_size);
    end
    
    % Create figure for combined results visualization
    figure('Name', 'Combined Masks Result');
    
    % Original masks sum
    subplot(1,2,1);
    imagesc(permute(sum(masks,3), [2,1]));
    hold on
    % Plot the main line if available
    if ~isempty(p.Results.startPoint) && ~isempty(p.Results.endPoint)
        line([p.Results.startPoint(1), p.Results.endPoint(1)], ...
             [p.Results.startPoint(2), p.Results.endPoint(2)], ...
             'Color', 'red', 'LineWidth', 1.5);
    end
    axis xy
    axis equal
    colorbar;
    title('Sum of Original Masks');
    
    % Combined masks sum
    subplot(1,2,2);
    imagesc(permute(sum(masks_combined,3), [2,1]));
    hold on
    % Plot the main line if available
    if ~isempty(p.Results.startPoint) && ~isempty(p.Results.endPoint)
        line([p.Results.startPoint(1), p.Results.endPoint(1)], ...
             [p.Results.startPoint(2), p.Results.endPoint(2)], ...
             'Color', 'red', 'LineWidth', 1.5);
    end
    axis xy
    axis equal
    colorbar;
    title(sprintf('Sum of Combined Masks\n(bin\\_size=%d, bin\\_sep=%d)', ...
        p.Results.bin_size, p.Results.bin_sep));
end

end 