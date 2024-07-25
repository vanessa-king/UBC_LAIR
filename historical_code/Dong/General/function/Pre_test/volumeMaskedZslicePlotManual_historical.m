
function [s, cuboidMask, comment] = volumeMaskedZslicePlotManual(dataCube, eslice, point, phi)
% display an vertical slice of a data cube through a defined point 
%   A vertival (parallel 3rd dimension) slice of the dataCube through the
%   point at an angle phi is displayed. Note: Only actual data included in
%   dataCube is displayed at the discrete location as indicated by the mask. 
%   The data is NOT inperpolated to represent datapoints on a planar slice.
%   
%   arguments:
%   dataCube    I(V), dIdV, ... data form a grid in the format data(x,y,z)
%   point       (x,y,z) coordinates of a point, defaults to the center of 
%               dataCube
%   phi         angle defining the rotation of the plane about the axis 
%               parallel to z intersecting point, defaults to 0
%
%   returns:
%   s           slice plot (to be checked if the figue should be returned
%               insted?)
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

    %create cuboid mask (ToDo: make cuboidMask an optional input and
    %default to running this section of no mask is given)
    [cuboidMask, ~, point, phi] = volumeMaskZslice(dataCube,eslice, point, phi);
    point = cat(2,point,1);

    
    %plot slice in 3D

    %create XYZ coordinates for the plot based on the datacube dimensions
    sz = size(dataCube);
    [X, Y, Z] = meshgrid(1:sz(1), 1:sz(2), 1:sz(3)); 
    %define surface for slice
    xsurf = reshape(X(cuboidMask),[length(find(cuboidMask(:,:,1))), sz(3)]); 
    ysurf = reshape(Y(cuboidMask),[length(find(cuboidMask(:,:,1))), sz(3)]);
    zsurf = reshape(Z(cuboidMask),[length(find(cuboidMask(:,:,1))), sz(3)]);
    
    %actual plot & parameters for the figure
    figure()
    s = slice(X,Y,Z,dataCube,xsurf,ysurf,zsurf);
    s.EdgeColor = 'none';
    axis xy
    grid on
    colormap(gray) 
    xlabel('x-axis')
    ylabel('y-axis');
    zlabel('z-axis');
    title('Vertical 2D slice of volumetric data')
    msg = sprintf('Startpoint: (x, y, z) = (%d, %d, %d); Angle: phi = %d', point(1),point(2),point(3),phi);
    subtitle(msg);
    xlim([1 size(dataCube,1)]);
    ylim([1 size(dataCube,2)]);
    zlim([1 size(dataCube,3)]);

    comment = sprintf('volumeMaskedZslicePlot(dataCube = [%d, %d, %d], point = [%d, %d, %d], phi = %d)', size(dataCube,1),size(dataCube,2),size(dataCube,3),point(1),point(2),point(3),phi);
end
