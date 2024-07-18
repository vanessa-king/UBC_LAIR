function [cuboidMask, comment, point, phi] = volumeMaskZslice(dataCube, eslice, point, phi)
% Mask a vertical slice of a data cube through a defined point 
%   A vertival (parallel 3rd dimension) slice of the dataCube through the
%   point at an angle phi is Masked. The line mask in the xy plane
%   defiend by a point and angle phi is extrapolated in the 3rd dimension.
% 
%   arguments:
%   dataCube    I(V), dIdV, ... data form a grid in the format data(x,y,z) 
%   point       (x,y,z) coordinates of a point, defaults to the center of 
%               dataCube
%   phi         angle [0, 360] defining the rotation of the plane about the 
%               axis parallel to z and intersecting point. Defaults to 0. 
%
%   returns:
%   cuboidMask  3D extrapolated mask representing the slice
%   comment     LOGcomment

% Feb. 2024, Markus Altthaler
% Feb. 2024, Dong Chen

arguments
    dataCube    
    eslice      {mustBeNumeric} = 1
    point       {mustBeNumeric} = []
    phi         {mustBeNumeric} = []
end
    %create mask in xy-plane 
    [mask, ~, point, phi] = gridMaskLine_new(dataCube(:,:,eslice), point, [], phi);
    point=cat(2,point,1);
    %create cuboid mask (extrapolate mask in 3rd dim)  
    cuboidMask= logical(ones(size(dataCube)).*mask); 

    comment = sprintf('volumeMaskedZslicePlot(dataCube = [%d, %d, %d], point = [%d, %d, %d], phi = %d)', size(dataCube,1),size(dataCube,2),size(dataCube,3),point(1),point(2),point(3),phi);

end
