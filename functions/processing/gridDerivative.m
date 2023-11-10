%Description: 
% This function generate a regular didv data set.

function [didv, V_reduced, comment] = gridDerivative(grid)
comment = sprintf("gridDerivative(grid:%s)|", mat2str(size(grid)));

V = grid.V; % pick array bias from grid 
I = grid.I; % pick array I from grid
V_reduced = V(1:end-1); % purpose: while performing dI/dV the data size get reduced by 1. 
% You can change the reduced data points from the head or the tail here.

didv = NaN(length(V_reduced),size(I,2),size(I,3));
for kx = 1:size(I,2)
    for ky = 1:size(I,3)
        didv(:,kx,ky) = diff(I(:,kx,ky))./diff(V); 
    end
end