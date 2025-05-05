function [norm_arr, norm_factor] = norm(arr, min_val)
% normalize between 0 and 1
% Inputs:
%   array: array to be normalized

% Outputs:
%   norm_factor: normalizization factor

norm_arr = (arr-min)/(max(arr)-min);
norm_factor = 1/(max(arr)-min);
end