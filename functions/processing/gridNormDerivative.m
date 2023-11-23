%Description: 
% This function generate a normalized didv data set, which requires an offset correction.

function [didv, I_correction, V_reduced, I_offset, comment] = gridNormDerivative(grid, C)

arguments
    grid
    C    {mustBeFloat}
end

comment = sprintf("gridNormDerivative(grid:%s, C=%s)|", mat2str(size(grid)),num2str(C));

V = grid.V; % pick array bias from grid 
I = grid.I; % pick array I from grid
V_reduced = V(1:end-1); % purpose: while performing dI/dV the data size get reduced by 1. 
% You can change the reduced data points from the head or the tail here.

% In any I-V curves, the current should be zero at bias=0 in most cases (there are some exceptions but rare). 
% However, the real data can have a systematic offset from the instrument. For example, bias output can have a very small 
% offset (i.e. the controller suppies some mV when the software is set to output 0 V. This can be
% corrected in the software by carefully checking the output. But if it wasn't corrected before the measurement 
% there could be an offset). For a proper calculation for a normalized didv this needs to be corrected. 
I_offset = NaN([size(I,2),size(I,3)]);
find(diff(sign(V))); 
[~,ind] = min(abs(V)); 
I_correction = NaN(size(I)); 
for kx = 1:size(I,2) 
    for ky = 1:size(I,3) 
            I_correction(:,kx,ky) = I(:,kx,ky)-I(ind,kx,ky); 
            I_offset(kx,ky) = I(ind,kx,ky);
    end
end

grid.I = I_correction;

% Now calculate normalized didv: i.e. (dI/dV)/(I/V)
[didv_corrected, ~, ~] = gridDerivative(grid);
didv = NaN(length(V_reduced),size(I,2),size(I,3));
for kx = 1:size(I,2)
    for ky = 1:size(I,3)
        normtemp = sqrt((I_correction(1:length(V_reduced),kx,ky)./V_reduced).^2+C^2);
        % C here is to deal with the diverging value at V=0 while normalizing.
        didv(:,kx,ky) = didv_corrected(:,kx,ky)./normtemp; % didv here is normalized didv.
    end
end