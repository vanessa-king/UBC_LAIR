% Description:   
%  Loads the files (called in the opening section of our script) in either the upward or downward
%  direction, to create "grid". Only one of upward or downward should be used. This code can handle a partial grid
% but truncates it in y not x.
% 
% Parameters:
%   folder: 3D Matrix with dI/dV data
%   stamp_project: the filename leader, takes the form 'yyyymmdd-XXXXXX_CaPt--STM_Spectroscopy--'
%   img_nbr: the z-file name, takes the form '###_#'
%   grd_nbr: the iv-file name, also takes the form '###_#'

function grid = gridLoadData(folder,stamp_project,img_number,grid_number, average_forward_and_backward)

%create the file names
Z_file = [stamp_project img_number '.Z_flat'];
I_file = [stamp_project grid_number '.I(V)_flat']; 

addpath(folder); 

% parse a FLAT-File and return its contents in a structure F, and then transform the FLAT data into a matrix

fZ = flat_parse(Z_file); 
mZ = flat2matrix(fZ); % this is a 3-d matrix: z, x, and y
fI = flat_parse(I_file);
mI = flat2matrix(fI); % this is a 4-d matrix: I, V, x, and y

rmpath(folder); 

% treatment of image data, by converting matrices into nanometers
% xraw and yraw are converted here as a clunky way of plotting in nm

xraw = 1e9*mZ{2}; 
yraw = 1e9*mZ{3};
zraw = mZ{1}; 

% check if image is scanned forwards AND backwards

if find(abs(diff(sign(diff(xraw))))) 
    
% but only take the forwards direction                                     
    grid.x_img = xraw(1:length(xraw)/2); 
    ztmp = zraw(1:length(xraw)/2,:);   
    
% or take the backwards direction
%   grid.x_img = xraw((length(xraw)/2+1):end);
%   ztmp = zraw((length(xraw)/2+1):end,:);

% do this if it was only scanned forwards (we DO have this option!)
else
    grid.x_img = xraw;
    ztmp = zraw;
     
end

% check if the image was swept up AND down

if find(abs(diff(sign(diff(yraw))))) 
  
  % but only take the up sweep
  grid.y_img_all = yraw(1:length(yraw)/2);
  grid.z_img_all = ztmp(:,1:length(yraw)/2); 
  
  % or take the down sweep
  %  grid.y_img_all = yraw((length(yraw)/2+1):end); 
  %  grid.z_img_all = ztmp(:,(length(yraw)/2+1):end);
  
% do this if it was only swept up  
else
    grid.y_img_all = yraw;
    grid.z_img_all = ztmp;
    
end

% This section is to remove NaN values in a partial image. If the image is complete, this section doesn't really do anything. 
grid.z_img = grid.z_img_all(:,all(~isnan(grid.z_img_all)));
sz1=size(grid.z_img,2);
grid.y_img = grid.y_img_all(1:sz1,1);

% uncomment this if you want to plot your images
% figure('Name','Topography');
% imagesc(grid.x_img,grid.y_img,grid.z_img');title('Z topography');xlabel('x / nm');ylabel('y / nm');axis image;axis xy;colorbar


% treatment of grid data, by converting matrices into nanometers

xraw = 1e9*mI{3};
yraw = 1e9*mI{4};
Vraw = mI{2};
Iraw = mI{1}; % mZ 3-dimensional; mI 4-dimensional (another one dimension is energy)

% the same comments included above apply below

if find(abs(diff(sign(diff(xraw))))) 
    
    grid.x = xraw(1:length(xraw)/2);
    Itmp = Iraw(:,1:length(xraw)/2,:);                                 
%   grid.x_all = xraw(:,(length(xraw)/2+1):end); 
%   Itmp = Iraw(:,(length(xraw)/2+1):end,:);
else
    grid.x = xraw;
    Itmp = Iraw;
end

if find(abs(diff(sign(diff(yraw))))) 
    
  grid.y_all = yraw(1:length(yraw)/2);
  I_dbl = Itmp(:,:,1:length(yraw)/2);    
  
%     grid.y_all = yraw((length(yraw)/2+1):end);  
%     I_dbl = Itmp(:,:,(length(yraw)/2+1):end); 
else
    grid.y_all = yraw;
    I_dbl = Itmp;
end

if find(abs(diff(sign(diff(Vraw))))) 
    
    NV = length(Vraw)/2;
    grid.V = Vraw(1:NV);
    grid.I_all = (I_dbl(1:NV,:,:)+flip(I_dbl(NV+1:2*NV,:,:),1))/2; 
    if (~average_forward_and_backward)
        grid.I_Forward_all = I_dbl(1:NV,:,:);
        grid.I_Backward_all = flip(I_dbl(NV+1:2*NV,:,:),1);
else
    grid.V = Vraw;
    grid.I_all = I_dbl;
end
    
    
grid.I_2D_all = squeeze(grid.I_all(1,:,:));    
grid.I_2D = grid.I_2D_all(:,all(~isnan(grid.I_2D_all)));
sz2=size(grid.I_2D,2);
grid.y = grid.y_all(1:sz2,1);
grid.I = grid.I_all(:,:,1:sz2);
grid.I_Forward = grid.I_Forward_all(:,:,1:sz2);
grid.I_Backward = grid.I_Backward_all(:,:,1:sz2);
end
