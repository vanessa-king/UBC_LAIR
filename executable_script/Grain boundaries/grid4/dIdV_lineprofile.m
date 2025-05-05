%% grid 4 TL
% plot dIdV along line profile 

profile = []; % initialize empty array
masks = data.grid4.directional_masks3;
pixel_size_nm = 10 / 50; % size of topo / number of points
distance = pixel_size_nm * (0:(size(profile,2)-1));

for i = 1:size(masks, 3)
    mask = masks(:,:,i); % assuming masks is a cell array of logical masks
    mask_expanded = repmat(mask, [1 1 size(data.grid4.dIdV_smoothed, 3)]);
    masked_data = data.grid4.dIdV_smoothed.*mask_expanded; % apply the mask
    value = squeeze(sum(masked_data, [1 2])); 
    [value_norm, norm_factor] = normRG(value, 0);
    profile(:, i) = value_norm; % 400 x number of masks
end
distance = pixel_size_nm * (0:(size(profile,2)-1));
profile_smoothed = smoothdata(profile, 1, 'gaussian', 15);
profile_smoothed = smoothdata(profile_smoothed, 2, 'gaussian', 3);

% HOMO LUMO onset
threshold = 0.1;
[LUMO_onset, HOMO_onset] = find_gap(profile_smoothed, data.grid4.V_reduced, threshold, 5);

% PLot them on the same plot
% (Optional) Plot the crossings
figure; hold on
imagesc(distance, data.grid4.V_reduced, profile_smoothed); 
set(gca, 'YDir', 'normal');
colormap('parula')
colorbar;
xlabel('Distance [nm]');ylabel('V_B [V]');
caxis([0, 1]);
scatter(distance, LUMO_onset, 'r', 'DisplayName', 'LUMO onset', 'SizeData',3);
scatter(distance, HOMO_onset, 'r', 'DisplayName', 'HOMO onset', 'SizeData',3);
yline(1, 'LineStyle','--', 'LineWidth',0.1)
yline(-2.19, 'LineStyle','--', 'LineWidth',0.1)
hold off
title('Grid 4, TL')

%% grid 4 BL
% plot dIdV along line profile 

profile = []; % initialize empty array
masks = data.grid4.directional_masksBL;
pixel_size_nm = 10 / 50; % size of topo / number of points
distance = pixel_size_nm * (0:(size(profile,2)-1));

for i = 1:size(masks, 3)
    mask = masks(:,:,i); % assuming masks is a cell array of logical masks
    mask_expanded = repmat(mask, [1 1 size(data.grid4.dIdV_smoothed, 3)]);
    masked_data = data.grid4.dIdV_smoothed.*mask_expanded; % apply the mask
    value = squeeze(sum(masked_data, [1 2])); 
    [value_norm, norm_factor] = normRG(value, 0);
    profile(:, i) = value_norm; % 400 x number of masks
end
distance = pixel_size_nm * (0:(size(profile,2)-1));
profile_smoothed = smoothdata(profile, 1, 'gaussian', 15);
profile_smoothed = smoothdata(profile_smoothed, 2, 'gaussian', 3);


% HOMO LUMO onset
threshold = 0.1;
[LUMO_onset, HOMO_onset] = find_gap(profile_smoothed, data.grid4.V_reduced, threshold, 5);

% PLot them on the same plot
% (Optional) Plot the crossings
figure; hold on
imagesc(distance, data.grid4.V_reduced, profile_smoothed); 
set(gca, 'YDir', 'normal');
colormap('parula')
colorbar;
xlabel('Distance [nm]');ylabel('V_B [V]');
caxis([0, 1]);
scatter(distance, LUMO_onset, 'r', 'DisplayName', 'LUMO onset', 'SizeData',3);
scatter(distance, HOMO_onset, 'r', 'DisplayName', 'HOMO onset', 'SizeData',3);
yline(0.9, 'LineStyle','--', 'LineWidth',0.1)
yline(-2.08, 'LineStyle','--', 'LineWidth',0.1)
hold off
title('Grid 4, BL')
