function [mask, comment] = logicORmask(maskA,maskB)
%Logic OR of two binary masks
%   Adds masks A and B and converts the sum into a logical maks. The 
%   returend  mask represents a logical OR, i.e. every elements where any 
%   of the two masks is 1 is also 1.

% M. Altthaler, March 2024

arguments
    maskA   {mustBeNumericOrLogical,mustBeNonnegative}
    maskB   {mustBeNumericOrLogical,mustBeNonnegative}
end

comment = "logicANDmask(maskA,maskB)";

if ismatrix(maskA) && ismatrix(maskB) && size(maskA,1) == size(maskB,1) && size(maskA,2) == size(maskB,2)
    mask = logical(maskA+maskB); %all non zero elements are converted to 1's 
end

end