function [norm_arr, norm_factor] = normRG(arr, min_val)
% normalize between 0 and 1
% Inputs:
%   array: array to be normalized

% Outputs:
%   norm_factor: normalizization factor

norm_arr = (arr-min_val)/(max(arr)-min_val);
norm_factor = 1/(max(arr)-min_val);
end