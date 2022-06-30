%Description:
%Parameters:
%%Input Parameters:
% grid : 1x1 structure, the matrix-style data
%%Output Parameters:
% dIdVN : array, Nanonis-style data 

function [IV, dIdV, label, elayer, xsize, ysize, emax, emin, avg_dIdV, avg_IV] = matrixToNanonis(grid, C, smooth)

IV = permute(grid.I, [3,2,1]);

[dIdV,~,~,~] = gridCorrNorm(grid, C, smooth);
dIdV = permute(dIdV, [3,2,1]);

label = grid.V;

elayer = size(label,1);

xsize = size(grid.x,1);

ysize = size(grid.y,1);

if grid.V(elayer)>grid.V(1)
    emax = grid.V(elayer);
    emin = grid.V(1);
else
    emax = grid.V(1);
    emin = grid.V(elayer);


for k=1:elayer-1
    avg_dIdV(k) = mean(mean(dIdV(:,:,k)));
    avg_IV(k) = mean(mean(IV(:,:,k)));
end

end