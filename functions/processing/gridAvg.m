function [avg_X, comment] = gridAvg(X, mask)
%This function takes the average of input data, X. 
% Usually it's either I(V) or dI/dV(V) from the grid measurement so it's a 3D matrix. 
% For example, grid.I has a size of I data points (same size of number_bias_layer) x grid size x grid size
% The function was re-written to have an option to accept a mask. Edited by Jisun Feb 2024. 

arguments
    X 
    mask = []
end

if isempty(mask)
    % Perform simple averaging
    % avg_X is the mean of grid.X based on the dimensions specified in the vector [a b]. 
    % Here, [2 3] is the total grid size: for example, if the size of grid.I is
    % 500x57x57, mean (grid.I [2 3]) will give averaged I over the total grid size of 57x57. 
    % The order of those numbers does not matter (i.e. [2 3] and [3 2] will give same mean values).
    avg_X = mean(X, [2 3]);
    comment = sprintf("gridAvg(I or dIdV:%s)|", mat2str(size(X)));
else
    % Compute masked average
    [xrow,ycol] = find(mask);
    for i = 1:length(xrow)
        X_cropped(:,i,i) = X(:,xrow(i),ycol(i)); % here the original X is cropped to only store data where the mask is applied.
    end
    % Calculate average of X from only masked area
    avg_X = mean(X_cropped, [2 3]);
    comment = sprintf("gridAvg(I or dIdV:%s) with mask applied|", mat2str(size(X)));
end

end





