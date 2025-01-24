function [mask, comment] = logicANDmask(maskA,maskB)
%Logic AND of two binary masks
%   Converts masks A and B into logical matrices and returns a mask that
%   represents a logical AND, i.e. only elements where both masks where 1
%   are 1

% M. Altthaler, March 2024

arguments
    maskA   {mustBeNumericOrLogical,mustBeNonnegative}
    maskB   {mustBeNumericOrLogical,mustBeNonnegative}
end

comment = "logicANDmask(maskA,maskB)";

if ismatrix(maskA) && ismatrix(maskB) && size(maskA,1) == size(maskB,1) && size(maskA,2) == size(maskB,2)
    mask = logical(maskA).*logical(maskB);
    mask = logical(mask); %convert to logical datatype 
end

end