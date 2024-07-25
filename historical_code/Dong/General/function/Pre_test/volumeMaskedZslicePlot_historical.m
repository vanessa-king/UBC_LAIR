
function [s, cuboidMask, comment] = volumeMaskedZslicePlot(dataCube,cuboidMask)
% display an vertical slice of a data cube defined by a mask
%   A vertival (parallel 3rd dimension) slice is displayed as defined by the
%   cuboidMask, generated via 'volumeMaskZslice.m'. Note: Only actual data 
%   included in dataCube is displayed at the discrete location as indicated
%   by the mask. The data is NOT inperpolated to represent datapoints on a 
%   planar slice.
%   
%   arguments:
%   dataCube    I(V), dIdV, ... data form a grid in the format data(x,y,z)
%   cuboidMask  logcal 3D mask of matchning dimensions
%
%   returns:
%   s           slice plot (to be checked if the figue should be returned
%               insted?)
%   cuboidMask  3D extrapolated mask representing the slice
%   comment     LOGcomment

% Feb. 2024, Markus Altthaler

arguments
    dataCube    
    cuboidMask
end

    comment = sprintf('volumeMaskedZslicePlot(dataCube = [%d, %d, %d], cuboidMask [%d, %d, %d]);', size(dataCube,1),size(dataCube,2),size(dataCube,3),cuboidMask(1),cuboidMask(2),cuboidMask(3));
    
    if size(dataCube) ~= size(cuboidMask)
        %stop fuction if mask mismatches data
        disp('cuboidMask does not match dimensions of the dataCube')
        return
    end
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
    msg = sprintf('based on supplied mask');
    subtitle(msg);
    xlim([1 size(dataCube,1)]);
    ylim([1 size(dataCube,2)]);
    zlim([1 size(dataCube,3)]);

end
