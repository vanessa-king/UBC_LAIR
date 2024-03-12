% Description:   
%  Loads the files (called in the opening section of our script) in either the upward or downward
%  direction, to create "grid". Only one of upward or downward should be used. This code can handle a partial grid
% but truncates it in y not x.
% 
% Parameters:
%   folder: 3D Matrix with dI/dV data
%   stamp_project: the filename leader, takes the form 'yyyymmdd-XXXXXX_CaPt--STM_Spectroscopy--'
%   img_number: the z-file name, takes the form '###_#'
%   grid_number: the iv-file name, also takes the form '###_#'

function [grid,comment] = gridLoadDataUpward(folder,stamp_project,img_number,grid_number,average_forward_and_backward)

%comment returns the data for the LOG comment: these are the name of the used function and the vlaues of the variables. "|" seperates
%the indidvidul values and termiantes the comment, thus also seperates concatenated comments of multiple functions used in one block.
%Note not all variables need to be tracked, e.g. do not convert the whole grid (x,y,I) values to a string! Only those that denote which type of
%processing is done.  

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Never plot data (e.g. the whole gird) in the comment, only plot the values
%('=<VARn_value>') of variables that decide/affect how the function
%processes data (e.g. order of fit, ...) 
%Note convert all <VARn_value> to strings; 

%comment = strcat("GridLoadData_Var:","folder",folder,"|",stamp_project,"|",num2str(img_number),"|",num2str(grid_number),"|",string(average_forward_and_backward),"|");
comment = sprintf("gridLoadDataUpward_separate(folder=%s, stamp_project=%s, img_number=%s, grid_number=%s, average_forward_and_backward=%s)|", folder, stamp_project, img_number, grid_number, mat2str(average_forward_and_backward));

%here the regular function 'begins' with data processing

%load the topo data
grid = topoLoadData(folder,stamp_project,img_number);

%create the file names
I_file = [stamp_project grid_number '.I(V)_flat']; 

addpath(folder); 

% parse a FLAT-File and return its contents in a structure F, and then transform the FLAT data into a matrix

fI = flat_parse(I_file);
mI = flat2matrix(fI); % this is a 4-d matrix: I, V, x, and y

rmpath(folder); 

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

% This section is to calculate where I(V) has NaN values and then remove them for a partial image/grid. 

ratio = grid.reduced_topo_size/size(grid.y_img_all,1);
reduced_grid_size = ceil(ratio*size(grid.y_all,1));
grid.y = grid.y_all(1:reduced_grid_size,1);
grid.I = grid.I_all(:,:,1:reduced_grid_size);
grid.I_Forward = grid.I_Forward_all(:,:,1:reduced_grid_size);
grid.I_Backward = grid.I_Backward_all(:,:,1:reduced_grid_size);

end