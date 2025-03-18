function [mask,posOut, comment] = maskPolygon(data, n, V_reduced, imageV, positionsIn)
%Draw a n-point polygon mask on a 2D image or grid slice. 
%   The function dispalys a 2D image: topography or grid slice (the latter
%   requires V_reduced and imageV as inputs). The polygon shaped mask is 
%   defined by clicking on the image. To finish the selection the polygon 
%   needs to be closed (click start point). The image will display the
%   selected mask. In the mask the selected region of the polygon is 
%   represented by 1, the rest by 0.
%   The optional input parameter positionsIn allows to reproduce the mask.

%   returns:
%   mask        binary mask representing the polygon
%   posOut      list of clicked points
%   comment     for logging

%  M. Altthaler - 2025/02; 

arguments
    data        {mustBeNumeric}         % 2D/3D data, topo img or dIdV
    n           {mustBePositive} = []   % optional, only for 3D data
    V_reduced   {mustBeNumeric} = []    % optional, only for 3D data
    imageV      {mustBeNumeric} = []    % optional, only for 3D data
    positionsIn {mustBePositive} = []   % optional, to reproduce mask
end

% Check if data is 2D or 3D
[data_slice, imN, V_actual] = dataSlice2D(data,n,V_reduced,imageV);

% plot image of data slice
img = figure('Name', 'Select Mask Location by drawing a ploygon:');
imagesc(data_slice');
setGraphLayout("topoImage");
% get ROI via polygon
if isempty(positionsIn) 
    roi = drawpolygon(gca,"FaceAlpha",0.15);
else
    roi = drawpolygon(gca,'Position',positionsIn, 'FaceAlpha',0.15);
end
%asssign clicked positions as output variables (not rounded!) 
posOut = roi.Position;
% convert ROI to mask and log points list
mask = poly2mask(roi.Position(:,1),roi.Position(:,2),size(data_slice,2),size(data_slice,1))';
%plot mask over the image
imagesc(permute(mask, [2 1]));
setGraphLayout("topoImage");
img.Name = "Selected Mask";
% log comment of function call & picked positions
comment = sprintf("maskPolygon(data(:,:,imN = %s | V_actual = %s), V_reduced, imageV = %s, positions = %s); maskPolygon_roi.Position = %s", num2str(imN), num2str(V_actual), mat2str(imageV), mat2str(positionsIn),mat2str(posOut));

end