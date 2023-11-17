%Description:
% Transform processed Matrix data (a.k.a. the grid structure) to the processed Nanonis data format
%Parameters:
%%Input Parameters:
% grid : 1x1 structure, the matrix-style data
% didv: 3D Matrix with dI/dV data
%%Output Parameters:
% IV_NanonisStyle : [numx, numy, numV] array, Nanonis-style data version of grid.I
% dIdV_NanonisStyle : [numx, numy, numV] array, Nanonis-style data version of didv
% avg_dIdV_NanonisStyle: [numV] array, spatial average of dIdV, Nanonis-style format
% avg_IV_NanonisStyle: [numV] array, spatial average of IV, Nanonis-style format

function [IV_NanonisStyle, dIdV_NanonisStyle, avg_IV_NanonisStyle, avg_dIdV_NanonisStyle, comment] = matrixToNanonis(grid, didv)

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Note convert all <VARn_value> to strings; 
formatSpec="gridCorrectionNorm(grid:%s, didv:%s)";
comment = sprintf(formatSpec, mat2str(size(grid)), mat2str(size(didv)));

IV_NanonisStyle = permute(grid.I, [3,2,1]); % going from [numV, numx, numy] to [numx, numy, numV]
dIdV_NanonisStyle = permute(didv, [3,2,1]); % going from [numV, numx, numy] to [numx, numy, numV]

for k=1:elayer-1 % calculating average arrays. Note that we have to use a reduced elayer because gridCorrectionNorm reduces numV by 1.
    avg_dIdV_NanonisStyle(k) = mean(mean(dIdV_NanonisStyle(:,:,k)));
    avg_IV_NanonisStyle(k) = mean(mean(IV_NanonisStyle(:,:,k)));
end

end
