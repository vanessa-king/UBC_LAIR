function [s,comment] = volumeMaskedZslice2Dplot_Dong(dataCube,cuboidMask,energy_range)
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
% Feb. 2024, Dong Chen

arguments
    dataCube    
    cuboidMask
    energy_range    % The list of energy slices of the cuboid
end

    comment = sprintf('volumeMaskedZslicePlot(dataCube = [%d, %d, %d], cuboidMask [%d, %d, %d]);', size(dataCube,1),size(dataCube,2),size(dataCube,3),cuboidMask(1),cuboidMask(2),cuboidMask(3));
    
    if size(dataCube) ~= size(cuboidMask)
        %stop fuction if mask mismatches data
        disp('cuboidMask does not match dimensions of the dataCube')
        return
    end
    
    %get the discrete coordinates for all 1's in the mask
    [locationX,locationY] = find(cuboidMask(:,:,1));
    
    % A different way to obtain xy
    dl=zeros(size(locationX)-1);
    xy=zeros(size(locationX));
    vector=[locationX(end)-locationX(1), locationY(end)-locationY(1)];
    unit_vector=vector/norm(vector);

    for i =1:size(dl)
        dn=[locationX(i+1)-locationX(i),locationY(i+1)-locationY(i)];
        dl(i)= dot(dn,unit_vector);
        xy(i+1)=sum(dl);
    end
%% Plotting 

    s = pcolor(xy, energy_range, reshape(dataCube(cuboidMask),[length(xy),size(dataCube,3)])');
    set(s, 'edgecolor', 'none');
    
    
end
