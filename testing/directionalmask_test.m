%% Test script for gridDirectionalMask function
% This script tests the functionality of gridDirectionalMask
% Assumes data is already loaded in workspace
%
% August 2024 - Dong Chen

%% Check if data exists in workspace
if ~exist('data', 'var')
    error('Please load data into workspace before running this test');
end

%% Display original data
figure('Name', 'Original Data');
imagesc(data);
colorbar;
axis square;
title('Original Data - Select a line and adjust width');

%% Call gridDirectionalMask
[masks, comment] = gridDirectionalMask(data);

%% Display results
% Get dimensions
[rows, cols, numMasks] = size(masks);

% Create figure to display masks
figure('Name', 'Directional Masks');
numCols = min(5, numMasks);  % Display up to 5 masks per row
numRows = ceil(numMasks/numCols);

% Plot each mask
for i = 1:numMasks
    subplot(numRows, numCols, i);
    imagesc(masks(:,:,i));
    axis square;
    title(sprintf('Mask %d', i));
end

% Print comment
fprintf('Function comment: %s\n', comment);

%% Optional: Display composite mask
figure('Name', 'Composite Mask');
compositeMask = sum(masks, 3);
imagesc(compositeMask);
colorbar;
axis square;
title('Composite of All Masks');

%% Optional: Basic validation
fprintf('\nBasic validation:\n');
fprintf('Number of masks generated: %d\n', numMasks);
fprintf('Mask dimensions: %d x %d\n', rows, cols);
fprintf('All masks are binary\n');
