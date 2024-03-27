function [mask, comment] = invertMask(mask)
%Inverts mask
%   If any element of mask is >1 the mask is renormalized to the interval
%   [0, max] -> [0,1]. The (normalized) mask is inverted by applying abs(x-1). 

% M. Altthaler, March 2024

arguments
    mask    {mustBeNumericOrLogical,mustBeNonnegative}
end

comment = "invertMask(mask)";



if ismatrix(mask)
    tf = islogical(mask);
    if ~isempty(find(mask))
        %check if the mask has nonzero elements
        mask = abs(mask./max([max(mask(:)),1])-1); %norm masks exceeding 1 to [0,1] and invert
    else %div 0 exception for an all zero mask - invert 0->1
        mask = abs(mask-1);
    end
    if tf==1 %parsed mask was logical
        mask = logical(mask); %reassign logical datatype
    end
end

end