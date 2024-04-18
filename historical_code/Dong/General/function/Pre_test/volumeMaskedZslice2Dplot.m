function [s,comment] = volumeMaskedZslice2Dplot(dataCube,cuboidMask)
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

    %get the discrete coordinates for all 1's in the mask
    [locationX,locationY] = find(cuboidMask(:,:,1));
    %set a line as discrete points (1000 time the grid size) 
    xlineCoords = linspace(locationX(1),locationX(end),1000*max([size(cuboidMask,1),size(cuboidMask,2)]))';
    ylineCoords = linspace(locationY(1),locationY(end),1000*max([size(cuboidMask,1),size(cuboidMask,2)]))';
    %find the closest points on the point cloud (line [xlineCoords,ylineCoords]) 
    %to the querry points (i.e. discrete locations [locationX,locationY] 
    %of data points)
    P = [xlineCoords, ylineCoords];
    PQ = [locationX,locationY]; 
    k = dsearchn(P,PQ); 
    xlineCoords = xlineCoords(k);
    ylineCoords = ylineCoords(k);
    %calculate xy-line spacing:
    xy = sqrt((xlineCoords-xlineCoords(1)).^2 + (ylineCoords-ylineCoords(1)).^2)+1;
    
    s = pcolor(xy, 1:size(dataCube,3),reshape(dataCube(cuboidMask),[length(xy),size(dataCube,3)])');
    set(s, 'EdgeColor', 'none');
    
    
end
