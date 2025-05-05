% plot dIdV along line profile

profile = []; % initialize empty array
masks = data.grid3.directional_masks2;
pixel_size_nm = 10 / 55; % size of topo / number of points
distance = pixel_size_nm * (0:(size(profile,2)-1));

for i = 1:size(masks, 3)
    mask = masks(:,:,i); % assuming masks is a cell array of logical masks
    mask_expanded = repmat(mask, [1 1 size(data.grid3.dIdV_smoothed, 3)]);
    masked_data = data.grid3.dIdV_smoothed.*mask_expanded; % apply the mask
    value = squeeze(sum(masked_data, [1 2])); 
    [value_norm, norm_factor] = normRG(value, 0);
    profile(:, i) = value_norm; % 400 x number of masks
end
distance = pixel_size_nm * (0:(size(profile,2)-1));
profile_smoothed = smoothdata(profile, 1, 'gaussian', 5);
profile_smoothed = smoothdata(profile_smoothed, 2, 'gaussian', 3);
%profile_smoothed = (profile_smoothed - min(profile_smoothed, [], 1)) ./ (max(profile_smoothed, [], 1) - min(profile_smoothed, [], 1));
% Now plot the profile as a colormap
% figure;
% imagesc(distance, data.grid3.V_reduced, profile_smoothed); 
% set(gca, 'YDir', 'normal');
% colormap('parula')
% colorbar;
% xlabel('Distance [nm]');ylabel('V_B [V]');
% caxis([0, 1]);


% HOMO LUMO onset
threshold = 0.1;
[LUMO_onset, HOMO_onset] = find_gap(profile_smoothed, data.grid3.V_reduced, threshold, 5);

% (Optional) Plot the crossings
figure; hold on
imagesc(distance, data.grid3.V_reduced, profile_smoothed); 
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
title('Grid 3, DM2')