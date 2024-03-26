function [mask, comment] = logicORmask(maskA,maskB)
%Logic OR of two binary masks
%   Converts masks A and B into logical matrices and returns a mask that
%   represents a logical OR, i.e. every elements where any of the two masks 
%   is 1 is also 1.

% M. Altthaler, March 2024

arguments
    maskA   {mustBeNumericOrLogical,mustBeNonnegative}
    maskB   {mustBeNumericOrLogical,mustBeNonnegative}
end

comment = "logicANDmask(maskA,maskB)";

if ismatrix(maskA) && ismatrix(maskB)
    mask = logical(maskA+maskB); %all non zero elements are converted to 1's 
end

end