% Description:  
% Load topography from files with a z_flat format.
% Parameters:
%   folder: folder where z_flat files are stored
%   stamp_project: the filename leader, takes the form
%   'yyyymmdd-XXXXXX_CaPt--STM_Spectroscopy--', for example
%   img_number: the z-file name, takes the form '###_#'

function topo = topoLoadData_separate(folder,stamp_project,img_number)

arguments
    folder          {mustBeFolder}
    stamp_project   {mustBeText}
    img_number      {mustBeText}
end


Z_file = [stamp_project img_number '.Z_flat'];

addpath(folder);

% parse a FLAT-File and return its contents in a structure F, and then transform the FLAT data into a matrix
fZ = flat_parse(Z_file);
mZ = flat2matrix(fZ); % this is a 3-d matrix: z, x, and y

rmpath(folder);

% treatment of image data, by converting matrices into nanometers
% xraw and yraw are converted here as a clunky way of plotting in nm

xraw = 1e9*mZ{2};
yraw = 1e9*mZ{3};
zraw = mZ{1};

% check if image is scanned forwards AND backwards

if find(abs(diff(sign(diff(xraw)))))
    
% but only take the forwards direction
    topo.x_img = xraw(1:length(xraw)/2);
    ztmp = zraw(1:length(xraw)/2,:);
    
% or take the backwards direction
%   topo.x_img = xraw((length(xraw)/2+1):end);
%   ztmp = zraw((length(xraw)/2+1):end,:);

% do this if it was only scanned forwards (we DO have this option!)
else
    topo.x_img = xraw;
    ztmp = zraw;
end

% check if the image was swept up AND down
if find(abs(diff(sign(diff(yraw)))))

% but only take the up sweep
    topo.y_img_all = yraw(1:length(yraw)/2);
    topo.z_img_all = ztmp(:,1:length(yraw)/2);
    
% or take the down sweep
%   topo.y_img_all = yraw((length(yraw)/2+1):end); 
%   topo.z_img_all = ztmp(:,(length(yraw)/2+1):end);
  
% do this if it was only swept up  
else
    topo.y_img_all = yraw;
    topo.z_img_all = ztmp;
end

% This section is to remove NaN values in a partial image. If the image is complete, this section doesn't really do anything. 
topo.z_img = topo.z_img_all(:,all(~isnan(topo.z_img_all)));
topo.reduced_topo_size = size(topo.z_img,2);
topo.y_img = topo.y_img_all(1:topo.reduced_topo_size,1);

% uncomment this if you want to plot your images
% figure('Name','Topography');
% imagesc(topo.x_img,topo.y_img,topo.z_img');
% title('raw topography');xlabel('x (nm)');ylabel('y (nm)');
% axis image;axis xy;colorbar; colormap('gray')

end

