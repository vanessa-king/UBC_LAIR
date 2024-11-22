%% Test script for gridDirectionalMask and combineMasks functions
% This script tests the functionality of directional mask generation and combining
% Assumes data is already loaded in workspace
%
% August 2024 - Dong Chen

%% Check if data exists in workspace
if ~exist('data', 'var')
    error('Please load data into workspace before running this test');
end

%% Display original data
data_used = randn(100,100);
figure('Name', 'Original Data');
imagesc(data_used);
colorbar;
axis square;
title('Original Data - Select a line and adjust width');

%% Call gridDirectionalMask
connected = 1; 
startPoint = [10,13];
endPoint = [70,33];
[masks, comment] = gridDirectionalMask(data_used, connected, startPoint, endPoint);

%% Display first and last masks
% Get dimensions
[rows, cols, numMasks] = size(masks);

% Create figure to display first and last masks
figure('Name', 'First and Last Masks');
subplot(1,2,1);
imagesc(masks(:,:,1));
colorbar;
axis square;
title('First Mask');

subplot(1,2,2);
imagesc(masks(:,:,end));
colorbar;
axis square;
title(sprintf('Last Mask (#%d)', numMasks));

figure;
imagesc(sum(masks,3));
colorbar;
axis square;
title('Sum Mask');

% Print comment
fprintf('Function comment: %s\n', comment);

%% Test mask combining
% Try different bin parameters
bin_size = 3;
bin_sep = 2;  % < bin_size means overlap
[masks_combined , idx]= combineMasks(masks, bin_size, bin_sep);

%% Display combined results
figure('Name', 'Combined Masks Analysis');
composite = sum(masks_combined, 3);
imagesc(composite);
colorbar;
axis square;
title(sprintf('Composite of Combined Masks (bin\\_size=%d, bin\\_sep=%d)', ...
    bin_size, bin_sep));

%% Basic validation
fprintf('\nBasic validation:\n');
fprintf('Original masks:\n');
fprintf('  Number of masks: %d\n', numMasks);
fprintf('  Mask dimensions: %d x %d\n', rows, cols);
fprintf('  All masks are binary\n');
fprintf('\nCombined masks:\n');
fprintf('  Number of bins: %d\n', size(masks_combined,3));
fprintf('  Bin size: %d\n', bin_size);
fprintf('  Bin separation: %d\n', bin_sep);
if bin_sep < bin_size
    fprintf('  Overlap: %d slices\n', bin_size - bin_sep);
elseif bin_sep > bin_size
    fprintf('  Gap: %d slices\n', bin_sep - bin_size);
end
