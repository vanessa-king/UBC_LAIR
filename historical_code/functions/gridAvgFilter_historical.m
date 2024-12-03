function [avg_iv, comment] = gridAvgFilter_historical(iv_data, V, filter_indices)
%GRIDAVGFILTER Finds average didv with index filter applied
%   filter_indices = 1D array of indices in iv grid to average over

% missing explanation of variables! 

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Never plot data (e.g. the whole gird) in the comment, only plot the values
%('=<VARn_value>') of variables that decide/affect how the function
%processes data (e.g. order of fit, ...) 
%Note convert all <VARn_value> to strings; 
comment = sprintf("gridAvgFilter(iv_data, V, filter_indices)|");


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

