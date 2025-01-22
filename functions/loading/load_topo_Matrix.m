function topo = load_topo_Matrix(folder,topoFileName)
%Wrapper function for loading topos from Matrix (.Z_flat)
%   V.K. - Jan 2025
%   Based on the old function 'topoLoadData.m'.
%   Uses flat_parse and flat2matrix functions, processes the data into a structure 
% Input: 
%   folder: string of folder containing data
%   topoFileName: string of the fileName including the extension
% Output: 
%   topo: structure containing all the topo associated data
%   comment: string containing log comment

arguments
    folder          {mustBeFolder}
    topoFileName    {mustBeText}
end

%regular function processing:

addpath(folder);
flat = flat_parse(topoFileName);
topo.header = rmfield(flat,'phys_data'); %define header as everything but the data
[matrix, matrix_header] = flat2matrix(flat); 
topo.header.matrix_header = matrix_header; %add header defined in flat2matrix
rmpath(folder);

% treatment of image data, by converting matrices into nanometers
% xraw and yraw are converted here as a clunky way of plotting in nm

zraw = matrix{1};
xraw = 1e9*matrix{2};
yraw = 1e9*matrix{3};


% check if image is scanned forwards AND backwards

if find(abs(diff(sign(diff(xraw)))))
    
% but only take the forwards direction
    topo.x = xraw(1:length(xraw)/2);
    ztmp = zraw(1:length(xraw)/2,:);
    
% or take the backwards direction
%   topo.x = xraw((length(xraw)/2+1):end);
%   ztmp = zraw((length(xraw)/2+1):end,:);

% do this if it was only scanned forwards (we DO have this option!)
else
    topo.x = xraw;
    ztmp = zraw;
end

% check if the image was swept up AND down
if find(abs(diff(sign(diff(yraw)))))

% but only take the up sweep
    topo.y_all = yraw(1:length(yraw)/2);
    topo.z_all = ztmp(:,1:length(yraw)/2);
    
% or take the down sweep
%   topo.y_all = yraw((length(yraw)/2+1):end); 
%   topo.z_all = ztmp(:,(length(yraw)/2+1):end);
  
% do this if it was only swept up  
else
    topo.y_all = yraw;
    topo.z_all = ztmp;
end

% This section is to remove NaN values in a partial image. If the image is complete, this section doesn't really do anything. 
topo.z = topo.z_all(:,all(~isnan(topo.z_all)));
topo.reduced_topo_size = size(topo.z,2);
topo.y = topo.y_all(1:topo.reduced_topo_size,1);

end
