%Description:
% Transform processed Matrix data (a.k.a. the grid structure) to the processed Nanonis data format
%Parameters:
%%Input Parameters:
% grid : 1x1 structure, the matrix-style data
% C : normalization parameter, float
% smooth : True/False for whether to smooth or not
% normalize : True/False for whether to normalize or not
%%Output Parameters:
% IV : [numx, numy, numV] array, Nanonis-style data version of grid.I
% dIdV : [numx, numy, numV] array, Nanonis-style data version of didv
% label : array, Nanonis-style data version of grid.V
% elayer: integer, number of energy values
% xsize: integer, number of x values
% ysize: integer, number of y values
% emax: double, maximum energy value
% emin: double, minimum energy value
% avg_dIdV: [numV] array, spatial average of dIdV, the nanonis style format
% avg_IV: [numV] array, spatial average of IV, the nanonis style format

function [IV, dIdV, label, elayer, xsize, ysize, emax, emin, avg_dIdV, avg_IV, comment] = matrixToNanonis(grid, C, smooth, normalize)

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Note convert all <VARn_value> to strings; 
formatSpec="gridCorrectionNorm(grid=%s, C=%.3g, smooth=%d, normalize=%d)";
comment = sprintf(formatSpec, grid, C, smooth, normalize);

IV = permute(grid.I, [3,2,1]); % going from [numV, numx, numy] to [numx, numy, numV]

[didv,~,~,~] = gridCorrectionNorm(grid, C, smooth, normalize); % first producing matrix-style didv
dIdV = permute(didv, [3,2,1]); % going from [numV, numx, numy] to [numx, numy, numV]

label = grid.V;

elayer = size(label,1);

xsize = size(grid.x,1);

ysize = size(grid.y,1);

if grid.V(elayer)>grid.V(1) % figuring out if the max voltage is at the start or end
    emax = grid.V(elayer);
    emin = grid.V(1);
else
    emax = grid.V(1);
    emin = grid.V(elayer);


for k=1:elayer-1 % calculating average arrays. Note that we have to use a reduced elayer because gridCorrectionNorm reduces numV by 1.
    avg_dIdV(k) = mean(mean(dIdV(:,:,k)));
    avg_IV(k) = mean(mean(IV(:,:,k)));
end

end
