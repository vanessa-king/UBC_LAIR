function [mean_out,STD_out,comment] = xyPlanarMeanSTD(data,mask)
%Mean and STD of the planes along the 3rd dim of masked data
%   For a 3D data set data(x,y,z) the mean and standard deviation in the xy
%   plane are calculated for all elements as denoted by the xy plane mask.
%   1 x z arrays of average_out, and STD_out , as well as a comment for
%   logging the function are returned.

% M. Altthaler, March 2024

arguments
    data    {mustBeNumeric}
    mask    {mustBeNumericOrLogical} = size(data,[1,2])
end

comment = "[mean_out,STD_out,comment] = xyPlanarMeanSTD(data,mask)";
if ismatrix(mask)
    %2D mask parsed
    %calc avg and std
    mask(mask==0) = NaN;
    data = data.*mask;
    mean_out = mean(data,[1,2],"omitnan");
    STD_out = std(data,1,[1,2],"omitnan"); %note TBD is w=0 or w=1 is the right way to do it (see documentation for details)
else
    disp('Mask dimensions incompatible')
end

end