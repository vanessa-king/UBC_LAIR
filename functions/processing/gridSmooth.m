function [smoothed_data, comment] = gridSmooth(data, time, data_name, time_name)
% GRIDSMOOTH Applies moving-average smoothing on data vs. time.
%   data = data to be smoothed (3D matrix). Size n x length(time) x length(time)
%   time = independent variable axis to plot data against
%   data_name = a string indicating the name of the data (e.g., 'grid.I')
%   time_name = a string indicating the name of the time variable (e.g., 'time')

% No default values needed here.
arguments
   data
   time
   data_name
   time_name
end

% Generate the comment
comment = sprintf("gridsmooth(%s: %s, %s: %s)|", data_name, mat2str(size(data)), time_name, mat2str(size(time)));

smoothed_data = zeros(size(data));
[~, second_dim, third_dim] = size(data);
for i = 1:second_dim
    for j = 1:third_dim
        smoothed_data(:, i, j) = smooth(time, data(:, i, j));
    end
end

end