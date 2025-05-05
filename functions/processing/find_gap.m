function [HOMO_onset, LUMO_onset] = find_gap(profile, V, threshold, min_consecutive)
% FIND_GAP - Find HOMO and LUMO onsets by flipping negative energies correctly
% Inputs:
%   profile - (energy x position) array
%   V - energy axis (1D array)
%   threshold - threshold value
%   min_consecutive - minimum consecutive points above threshold
% Outputs:
%   HOMO_onset, LUMO_onset - 1D arrays of onset energies per position

HOMO_onset = NaN(1, size(profile, 2));
LUMO_onset = NaN(1, size(profile, 2));

for i = 1:size(profile, 2)
    curve = profile(:, i);

    % Split into negative and positive sides
    neg_idx = V < 0;
    pos_idx = V > 0;

    V_neg = V(neg_idx);
    curve_neg = curve(neg_idx);

    V_pos = V(pos_idx);
    curve_pos = curve(pos_idx);

    % --- Process negative side (HOMO) ---
    V_neg_flipped = -flip(V_neg);       % flip AND make positive
    curve_neg_flipped = flip(curve_neg); % flip curve values

    above_neg = curve_neg_flipped > threshold;
    d_neg = diff([0; above_neg; 0]);
    starts_neg = find(d_neg == 1);
    ends_neg = find(d_neg == -1) - 1;
    valid_neg = (ends_neg - starts_neg + 1) >= min_consecutive;
    starts_neg = starts_neg(valid_neg);

    if ~isempty(starts_neg)
        energies_crossed_neg = V_neg_flipped(starts_neg);
        [~, idx_min_neg] = min(energies_crossed_neg); % closest to 0
        selected_energy = energies_crossed_neg(idx_min_neg);
        HOMO_onset(i) = -selected_energy; % flip back to negative
    end

    % --- Process positive side (LUMO) ---
    above_pos = curve_pos > threshold;
    d_pos = diff([0; above_pos; 0]);
    starts_pos = find(d_pos == 1);
    ends_pos = find(d_pos == -1) - 1;
    valid_pos = (ends_pos - starts_pos + 1) >= min_consecutive;
    starts_pos = starts_pos(valid_pos);

    if ~isempty(starts_pos)
        energies_crossed_pos = V_pos(starts_pos);
        [~, idx_min_pos] = min(energies_crossed_pos); % closest to 0
        LUMO_onset(i) = energies_crossed_pos(idx_min_pos);
    end
end

end



