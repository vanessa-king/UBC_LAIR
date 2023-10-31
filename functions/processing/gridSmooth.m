function [smoothed_data, comment] = gridSmooth(data, data_name, span)
%GRIDSMOOTH Applies moving-average smoothing on data.
%   data = data to be smoothed (3D matrix). 
%   data_name = a string indicating the name of the data (e.g., 'grid.I')
%   span = the number of data points for calculating the smoothed value
%   (i.e.the size of the moving window). It needs to be an odd integer. Deafult is 3 (nearest neighbor
%   averaging) but you can use 5 for next nearest neighbor averaging. Or
%   higher, if necessary. 


% No default values needed here.
arguments
   data
   data_name    {mustBeText}
   span         =3   
end

% Generate the comment
comment = sprintf("gridsmooth(%s, %s, %s)|", data_name, mat2str(size(data)),mat2str(span));

smoothed_data = zeros(size(data));
[~, second_dim, third_dim] = size(data);
for i = 1:second_dim
    for j = 1:third_dim
        smoothed_data(:, i, j) = smooth(data(:, i, j), span);
    end
end

end