function [corrected_data, streak_indices] = interpolateLocalStreaks(Y, slice_idx, min_value, provided_streak_indices)
%INTERPOLATELOCALSTREAKS Interactive streak interpolating tool using Laplacian and neighbor interpolation
%   [corrected_data, streak_indices] = interpolateLocalStreaks(Y, slice_idx, min_value, provided_streak_indices)
%   processes 3D data Y using two methods: Laplacian-based detection followed by neighbor interpolation
%
%   Inputs:
%       Y - 3D data array
%       slice_idx - Optional index of the slice to process. If not provided and Y is 3D,
%                  will display the dataset for slice selection (only in interactive mode)
%       min_value - Optional minimum value for streak detection (default: interactive)
%       provided_streak_indices - Optional Nx2 array of [row,col] indices for streak points.
%                               If provided, skips interactive detection and applies these indices
%
%   Outputs:
%       corrected_data - The corrected image data (2D if single slice, 3D if full dataset)
%       streak_indices - Nx2 array of [row,col] indices for streak points
%
%   Example:
%       % Interactive mode
%       [corrected, indices] = interpolateLocalStreaks(Y);  % Interactive slice selection
%       [corrected, indices] = interpolateLocalStreaks(Y, 150);  % Specific slice
%
%       % Non-interactive mode with provided indices
%       [corrected] = interpolateLocalStreaks(Y, [], [], provided_indices);

% Handle 3D data and slice selection
if ndims(Y) == 3
    % If streak indices are provided, apply to all slices without interactive selection
    if nargin >= 4 && ~isempty(provided_streak_indices)
        corrected_data = zeros(size(Y));
        streak_indices = provided_streak_indices;
        
        % Process each slice
        for s = 1:size(Y,3)
            [corrected_data(:,:,s), ~] = interpolateLocalStreaks(Y(:,:,s), 1, min_value, streak_indices);
        end
        return;
    end
    
    % Interactive mode: need to select reference slice
    if nargin < 2 || isempty(slice_idx)
        % Display 3D dataset for slice selection
        figure;
        d3gridDisplay(abs(Y), 'dynamic');
        slice_idx = input('Enter the slice number for streak detection: ');
        close;
    end
    
    % Get reference slice for streak detection
    ref_slice = Y(:,:,slice_idx);
    [~, streak_indices] = interpolateLocalStreaks(ref_slice, 1, min_value);
    
    % Apply streak removal to all slices
    corrected_data = zeros(size(Y));
    for s = 1:size(Y,3)
        [corrected_data(:,:,s), ~] = interpolateLocalStreaks(Y(:,:,s), 1, [], streak_indices);
    end
    return;
end

% Initialize for 2D data
if nargin < 2
    slice_idx = 1;
end
if nargin < 3
    min_value = [];
end
corrected_data = [];
streak_indices = [];

% Process data
data = Y;
[rows, cols] = size(data);

% If streak indices are provided, directly apply interpolation
if nargin >= 4 && ~isempty(provided_streak_indices)
    corrected_data = data;
    streak_indices = provided_streak_indices;
    
    % Process each provided streak point
    for i = 1:size(provided_streak_indices, 1)
        r = provided_streak_indices(i,1);
        c = provided_streak_indices(i,2);
        
        % Check if both left and right neighbors are also streak points
        left_check = ismember([r, c-1], provided_streak_indices, 'rows');
        right_check = ismember([r, c+1], provided_streak_indices, 'rows');
        
        % Only process if both neighbors are streak points
        if left_check && right_check
            % Get neighboring points
            neighbors = [data(r,c-1), data(r,c+1)];
            
            % Replace streak with mean of neighbors
            corrected_data(r,c) = mean(neighbors);
        end
    end
    return;
end

% Compute Laplacian
L = zeros(size(data));
% Shift left and right
data_left = [zeros(rows,1), data(:,1:end-1)];
data_right = [data(:,2:end), zeros(rows,1)];
% Compute Laplacian using matrix operations
L = data_left + data_right - 2*data;
L_mag = abs(L);

% Create figure and store its handle
h_fig = figure('Name', 'X-Direction Laplacian Streak Removal Analysis', 'Position', [100, 100, 1200, 800]);

% Plot original data
subplot(2, 2, 1);
imagesc(data);
title('Original Data');
axis square;
colormap parula;
colorbar;

% Plot Laplacian
subplot(2, 2, 2);
h_plot = imagesc(L_mag);
title('X-Direction Laplacian Magnitude');
axis square;
colormap parula;
colorbar;

% Plot histogram
subplot(2, 2, 3);
h_hist = histogram(L_mag);
title('Histogram of Laplacian Magnitude');
axis square;
hold on;
h_min_line = xline(min(L_mag(:)), 'r-', 'LineWidth', 2);
h_max_line = xline(max(L_mag(:)), 'r-', 'LineWidth', 2);
xlim([min(L_mag(:)), max(L_mag(:))/2]);  % Set x-axis range to half of max
hold off;

% Plot corrected image
subplot(2, 2, 4);
h_corrected = imagesc(data);
title('Corrected Image');
axis square;
colormap parula;
colorbar;

% Create controls
panel = uipanel('Position', [0.1, 0.02, 0.8, 0.05]);

% Initialize slider value based on whether min_value was provided
initial_min = min(L_mag(:));
if ~isempty(min_value)
    initial_min = min_value;
end

% Min slider
uicontrol(panel, 'Style', 'text', 'String', 'Min:', 'Position', [10, 5, 40, 20]);
min_slider = uicontrol(panel, 'Style', 'slider', ...
    'Min', min(L_mag(:)), ...
    'Max', max(L_mag(:))/2, ...
    'Value', initial_min, ...
    'Position', [60, 5, 300, 20]);

% Add value display
min_text = uicontrol(panel, 'Style', 'text', ...
    'String', sprintf('%.3f', initial_min), ...
    'Position', [370, 5, 60, 20]);

% Done button
done_button = uicontrol(panel, 'Style', 'pushbutton', ...
    'String', 'Done', ...
    'Position', [450, 5, 100, 40], ...
    'Callback', @(src,event) finish(src, h_corrected, h_plot));

% Set up callbacks
set(min_slider, 'Callback', @(src,event) updateContrast(src, event, h_plot, min_text, h_corrected, data, L_mag, h_min_line, h_max_line, done_button));

% Initialize display
updateContrast(min_slider, [], h_plot, min_text, h_corrected, data, L_mag, h_min_line, h_max_line, done_button);

% Wait for the figure to be closed
waitfor(h_fig);

% Get results from the base workspace
if evalin('base', 'exist(''temp_corrected_data'', ''var'')')
    corrected_data = evalin('base', 'temp_corrected_data');
    streak_indices = evalin('base', 'temp_streak_indices');
    evalin('base', 'clear temp_corrected_data temp_streak_indices');
end

end

function finish(src, h_corrected, h_plot)
    % Get the current values from the button's UserData
    user_data = get(src, 'UserData');
    min_val = user_data(1).min_val;
    max_val = user_data(1).max_val;
    
    % Get the results
    corrected_data = get(h_corrected, 'CData');
    streak_mask = get(h_plot, 'CData') >= min_val & get(h_plot, 'CData') <= max_val;
    [streak_rows, streak_cols] = find(streak_mask);
    streak_indices = [streak_rows, streak_cols];
    
    % Store results in base workspace
    assignin('base', 'temp_corrected_data', corrected_data);
    assignin('base', 'temp_streak_indices', streak_indices);
    
    % Close the figure
    close(gcf);
end

function updateContrast(src, ~, h_plot, min_text, h_corrected, data, L_mag, h_min_line, h_max_line, done_button)
    % Get current values
    min_val = get(src, 'Value');
    max_val = max(L_mag(:));
    
    % Update display
    caxis(h_plot.Parent, [min_val, max_val]);
    set(min_text, 'String', sprintf('%.3f', min_val));
    set(h_min_line, 'Value', min_val);
    set(h_max_line, 'Value', max_val);
    
    % Find streaks
    streak_mask = L_mag >= min_val & L_mag <= max_val;
    [streak_rows, streak_cols] = find(streak_mask);
    streak_indices = [streak_rows, streak_cols];
    
    % Correct streaks using consistent method
    corrected = data;
    [rows, cols] = size(data);
    
    % Process each streak point
    for i = 1:size(streak_indices, 1)
        r = streak_indices(i,1);
        c = streak_indices(i,2);
        
        % Check if both left and right neighbors are also streak points
        left_check = ismember([r, c-1], streak_indices, 'rows');
        right_check = ismember([r, c+1], streak_indices, 'rows');
        
        % Only process if both neighbors are streak points
        if left_check && right_check
            % Get neighboring points
            neighbors = [data(r,c-1), data(r,c+1)];
            
            % Replace streak with mean of neighbors
            corrected(r,c) = mean(neighbors);
        end
    end
    
    % Update display
    set(h_corrected, 'CData', corrected);
    
    % Calculate new contrast limits based on corrected data
    valid_data = corrected(~isnan(corrected) & ~isinf(corrected));
    if ~isempty(valid_data)
        new_min = min(valid_data(:));
        new_max = max(valid_data(:));
        caxis(h_corrected.Parent, [new_min, new_max]);
    end
    
    set(done_button, 'UserData', struct('min_val', min_val, 'max_val', max_val));
    drawnow;
end


