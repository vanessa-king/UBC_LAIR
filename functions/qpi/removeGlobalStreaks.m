function [dIdV_nostreaks, QPI_nostreaks] = removeGlobalStreaks(dIdV, mask, direction)
% REMOVEGLOBALSTREAKS Removes global streaks from QPI data
%   This function removes global streaks from QPI data by normalizing each scan line.
%   The algorithm:
%   - Calculates mean and variance for each row and column
%   - Normalizes these lines to the global mean
%   - Can be applied to horizontal, vertical, or both directions
%   - Only processes non-NaN entries based on the input mask
%
% Inputs:
%   dIdV - 3D data array containing the dI/dV data
%   mask - (optional) 2D numeric mask where 1 indicates regions to process, other values will be set to NaN
%          If not provided, all regions will be processed
%   direction - (optional) 'none' (both), 'horizontal', or 'vertical'. Default is 'none'
%
% Outputs:
%   dIdV_nostreaks - Streak-removed dI/dV data
%   QPI_nostreaks - QPI of the streak-removed data
%
% Example:
%   [dIdV_nostreaks, QPI_nostreaks] = removeGlobalStreaks(dIdV)
%   [dIdV_nostreaks, QPI_nostreaks] = removeGlobalStreaks(dIdV, [], 'horizontal')
%   [dIdV_nostreaks, QPI_nostreaks] = removeGlobalStreaks(dIdV, mask, 'vertical')
%
% Created: May 2025
% Dong Chen

% Set default values for optional inputs
if nargin < 2
    mask = [];
end
if nargin < 3
    direction = 'none';
end

% Validate inputs
validateattributes(dIdV, {'numeric'}, {'3d'});
if ~isempty(mask)
    validateattributes(mask, {'numeric'}, {'2d'});
end
if ~ismember(direction, {'none', 'horizontal', 'vertical'})
    error('Direction must be ''none'', ''horizontal'', or ''vertical''');
end

x_num = size(dIdV,1); % x-direction scan size
y_num = size(dIdV,2); % y-direction scan size
points = size(dIdV,3); % number of points in bias sweep

% If mask is not provided, create a matrix of ones
if isempty(mask)
    mask = ones(x_num, y_num);
end

% Validate mask dimensions
if ~isequal(size(mask), [x_num, y_num])
    error('Mask dimensions must match the first two dimensions of dIdV');
end

% Create binary mask with NaN for non-1 values
binary_mask = ones(size(mask));
binary_mask(mask ~= 1) = NaN;

%% dIdV with no streaks

fprintf('Performing streak removal algorithm in %s direction\n', direction)

% Create empty variable for streak removal algorithm
dIdV_nostreaks = dIdV; % Initialize with original data

% for loop averages each scan line to zero
for k = 1:(points)
    % Apply mask to current slice
    current_slice = dIdV(:,:,k) .* binary_mask;
    
    % Calculate means and variances only for non-NaN values
    col_mean = zeros(1, y_num);
    col_var = zeros(1, y_num);
    row_mean = zeros(x_num, 1);
    row_var = zeros(x_num, 1);
    
    % Calculate column statistics using only non-NaN values
    for j = 1:y_num
        valid_data = current_slice(:,j);
        valid_data = valid_data(~isnan(valid_data));
        if ~isempty(valid_data)
            col_mean(j) = mean(valid_data);
            col_var(j) = var(valid_data, 0);
        else
            col_mean(j) = NaN;
            col_var(j) = NaN;
        end
    end
    
    % Calculate row statistics using only non-NaN values
    for i = 1:x_num
        valid_data = current_slice(i,:);
        valid_data = valid_data(~isnan(valid_data));
        if ~isempty(valid_data)
            row_mean(i) = mean(valid_data);
            row_var(i) = var(valid_data, 0);
        else
            row_mean(i) = NaN;
            row_var(i) = NaN;
        end
    end
    
    % Calculate global means excluding NaN values
    totalcol_mean = mean(col_mean(~isnan(col_mean)));
    totalrow_mean = mean(row_mean(~isnan(row_mean)));
    
    % Apply horizontal correction (rows)
    if strcmp(direction, 'none') || strcmp(direction, 'horizontal')
        for i = 1:x_num
            if ~isnan(row_mean(i))  % Only process if we have valid statistics
                % Apply correction to entire row, including NaN regions
                dIdV_nostreaks(i,:,k) = dIdV(i,:,k) - row_mean(i) + totalrow_mean;
            end
        end
    end
    
    % Apply vertical correction (columns)
    if strcmp(direction, 'none') || strcmp(direction, 'vertical')
        for j = 1:y_num
            if ~isnan(col_mean(j))  % Only process if we have valid statistics
                % Apply correction to entire column, including NaN regions
                dIdV_nostreaks(:,j,k) = dIdV(:,j,k) - col_mean(j) + totalcol_mean;
            end
        end
    end
end

% for loop finds abrupt tip changes during a scan line
% fcn findchangepoints is MATLAB built in, locates step edges
% if statement renormalises each line to average at zero
% for a = 1:size(dIdV_nostreaks,2)
%     clear ipt
% 
%     ipt = findchangepts(normalize(dIdV_nostreaks(:,a,1)),'Statistic','mean','MinThreshold',10);
% 
%     ipt = [1; ipt; size(dIdV_nostreaks,1)];
% 
%     % Normalize lines
% 
%     if size(ipt,1) > 2
%         for k = 1:(size(ipt,1)-1)
%             for b = 1:(size(dIdV_nostreaks,3))
%                 dIdV_nostreaks(ipt(k):ipt(k+1),a,b) = dIdV_nostreaks(ipt(k):ipt(k+1),a,b) - mean(mean(mean(dIdV_nostreaks(ipt(k):ipt(k+1),a,b))));
%             end
%         end
%     end
% end

% TAKE FOURIER TRANSFORM OF THE dIdV DATA with streaks removed
% 1. Subract the mean to remove the zero frequency spike
% 2. 2D fast Fourier transform using the FFT2 function
% 3. Shift the FFT2 result so zero frequency is at the center
% 4. Take modulus for plotting the intensity

fprintf('Fourier transforming \n')

QPI_nostreaks = zeros(x_num, y_num, points); % Create zero matrix for QPI results

for i = 1:(points)
    % Apply mask to current slice
    current_slice = dIdV_nostreaks(:,:,i) .* binary_mask;
    
    % Calculate mean excluding NaN values
    valid_data = current_slice(~isnan(current_slice));
    slice_mean = mean(valid_data);
    
    % Replace NaN with mean for FFT
    current_slice(isnan(current_slice)) = slice_mean;
    
    QPI_nostreaks(:,:,i) = abs(fftshift(fft2(current_slice - slice_mean)));
end

end

function [threshold_col, threshold_row] = getVarianceThresholds(col_var, row_var, x_num)
    % Helper function to get variance thresholds interactively
    
    % Create UI figure for column variance threshold
    uifig_col = uifigure('Name', 'Column Variance Threshold', 'Position', [100 100 800 600]);
    ax_col = uiaxes(uifig_col, 'Position', [50 50 700 500]);
    
    % Plot histogram of column variances
    histogram(ax_col, col_var, round(x_num/10));
    title(ax_col, 'Histogram of column variances');
    xlabel(ax_col, 'Variance');
    ylabel(ax_col, 'Frequency');
    
    % Calculate initial threshold suggestion
    initial_threshold = median(col_var);
    
    % Create interactive line for threshold
    h_col = images.roi.Line(ax_col, ...
        'Position', [initial_threshold 0; initial_threshold max(ylim(ax_col))]', ...
        'Label', 'Threshold', ...
        'LabelAlpha', 0.35, ...
        'InteractionsAllowed', 'translate', ...
        'MarkerSize', 1, ...
        'Color', [1 0 0], ...
        'StripeColor', 'w');
    
    % Add listener for line movement
    addlistener(h_col, 'MovingROI', @(src,evt) updateVerticalLine(src, evt, ax_col, 'Column'));
    
    % Add instructions text
    uilabel(uifig_col, 'Text', 'Press Enter to confirm threshold', ...
        'Position', [300 10 200 20], ...
        'HorizontalAlignment', 'center');
    
    % Wait for Enter key
    waitfor(uifig_col, 'CurrentCharacter', char(13));
    
    % Get final threshold
    threshold_col = h_col.Position(1,1);
    close(uifig_col);
    
    % Create UI figure for row variance threshold
    uifig_row = uifigure('Name', 'Row Variance Threshold', 'Position', [100 100 800 600]);
    ax_row = uiaxes(uifig_row, 'Position', [50 50 700 500]);
    
    % Plot histogram of row variances
    histogram(ax_row, row_var, round(x_num/10));
    title(ax_row, 'Histogram of row variances');
    xlabel(ax_row, 'Variance');
    ylabel(ax_row, 'Frequency');
    
    % Calculate initial threshold suggestion
    initial_threshold = median(row_var);
    
    % Create interactive line for threshold
    h_row = images.roi.Line(ax_row, ...
        'Position', [initial_threshold 0; initial_threshold max(ylim(ax_row))]', ...
        'Label', 'Threshold', ...
        'LabelAlpha', 0.35, ...
        'InteractionsAllowed', 'translate', ...
        'MarkerSize', 1, ...
        'Color', [1 0 0], ...
        'StripeColor', 'w');
    
    % Add listener for line movement
    addlistener(h_row, 'MovingROI', @(src,evt) updateVerticalLine(src, evt, ax_row, 'Row'));
    
    % Add instructions text
    uilabel(uifig_row, 'Text', 'Press Enter to confirm threshold', ...
        'Position', [300 10 200 20], ...
        'HorizontalAlignment', 'center');
    
    % Wait for Enter key
    waitfor(uifig_row, 'CurrentCharacter', char(13));
    
    % Get final threshold
    threshold_row = h_row.Position(1,1);
    close(uifig_row);
end

function updateVerticalLine(src, evt, ax, type)
    % Get current position
    pos = evt.CurrentPosition;
    
    % Get y-axis limits
    ylims = ylim(ax);
    
    % Update position to maintain vertical line
    newPos = [pos(1,1) ylims(1); pos(1,1) ylims(2)];
    src.Position = newPos;
    
    % Update title with current threshold value
    ax.Title.String = sprintf('%s Variance Threshold = %.3f', type, pos(1,1));
end


