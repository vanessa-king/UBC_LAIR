function [avg_X, comment] = gridAvg(X)
%This function takes the average of input data, X. 
% Usually it's either I(V) or dI/dV(V) from the grid measurement so it's a 3D matrix. 
% For example, grid.I has a size of I data points (same size of number_bias_layer) x grid size x grid size

arguments
    X 
end

comment = sprintf("gridAvg(I or dIdV:%s)|", mat2str(size(X)));

% avg_X is the mean of grid.X based on the dimensions specified in the vector [a b]. 
% Here, [2 3] is the total grid size: for example, if the size of grid.I is
% 500x57x57, mean (grid.I [2 3]) will give averaged I over the total grid size of 57x57. 
% The order of those numbers does not matter (i.e. [2 3] and [3 2] will give same mean values).

avg_X = mean(X, [2 3]);

end

