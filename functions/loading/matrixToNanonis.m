%Description:
%Parameters:
%%Input Parameters:
% grid : 1x1 structure, the matrix-style data
%%Output Parameters:
% dIdVN : array, Nanonis-style data 

function [IV, dIdV, label, elayer, xsize, ysize, emax, emin, avg_dIdV, avg_IV] = matrixToNanonis(grid, C, smooth, normalize)

IV = permute(grid.I, [3,1,2]);

[dIdV,~,~,~,~] = gridCorrectionNorm(grid, C, smooth, normalize);
dIdV = permute(dIdV, [3,1,2]);

label = grid.V;

elayer = size(label);

xsize = size(grid.x);

ysize = size(grid.y);

if grid.V(elayer)>grid.V(1)
    emax = grid.V(elayer);
    emin = grid.V(1);
else
    emax = grid.V(1);
    emin = grid.V(elayer);


avg_dIdV = NaN(elayer,1);
avg_IV = NaN(elayer,1);
for k=1:elayer
    avg_dIdV(k) = mean(mean(dIdV(:,:,k)));
    avg_IV(k) = mean(mean(IV(:,:,k)));
end

end