function [avg_iv] = gridAvgFilter(iv_data, V, filter_indices)
%GRIDAVGFILTER Finds average didv with index filter applied
%   filter_indices = 1D array of indices in iv grid to average over
[elayer, ~] = size(V);

iv_data_flip = flip(permute(iv_data,[1 3 2]),2); % flip didv so that image (x,y) = (0,0) at the bottom left

avg_iv = zeros(elayer, 1);
for i = 1:elayer
    slice = iv_data_flip(i,:,:);
    filtered = slice(filter_indices);
    avg = mean(filtered);
    avg_iv(i) = avg;
end
end

