% Requirements:
% Matlab 2021B or newer - 'pyrunfile' does not exist in older versions
% python 3.8 or newer. Type 'pyenv' in Matlab to see which python version Matlab recognizes

% Description:
% Reads Nanonis python-processed gridmap data and returns as grid structure
% Input: folder = string of folder containing data
%        stamp_project = the filename leader, takes the form 'yyyymmdd-XXXXXX_CaPt--STM_Spectroscopy--'
%        grid_number = string of 3ds file number, ie: 'NbIrPtTe001'
%        img_number = string of sxm file number, ie: '0012'
%        topoDirection = string of desired topo z scan direction, either
%        'forward' or 'backward'
% Output:grid = 1x1 structure containing x,y,I,V,x_img,y_img,z_img

function [grid, comment] = pythonDataToGrid(folder, stamp_project, grid_number, img_number, topoDirection)

arguments
    folder          {mustBeText}
    stamp_project   {mustBeText}
    grid_number     {mustBeText}
    img_number      {mustBeText}
    topoDirection   {mustBeText}
end

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Never plot data (e.g. the whole gird) in the comment, only plot the values
%('=<VARn_value>') of variables that decide/affect how the function
%processes data (e.g. order of fit, ...) 
%Note convert all <VARn_value> to strings; 
comment = sprintf("pythonDataToGrid(folder=%s, stamp_project=%s, grid_number=%s, topo_number=%s, topoDirection=%s)|", folder, stamp_project, grid_number, img_number, topoDirection);

%regular function processing:

gridFileName = strcat(folder,"/",stamp_project,grid_number,".3ds");
topoFileName = strcat(folder,"/",stamp_project,img_number,".sxm");

pythonScript_and_fileName = strcat("read_grid_data.py ",gridFileName, " ",topoFileName, " ", topoDirection);

python_Data = pyrunfile(pythonScript_and_fileName, "gridArrays"); %Calls pythonScript, gives the file names as input, gets gridArrays as output

python_Data_cell = cell(python_Data); %Turning from python List to cell array that contains python arrays


x = double(python_Data_cell{1}); %python array -> double array. Shape (num_x, num_y)
x = x(1,:);%We only require one row, (num_x, num_y) -> (num_x,1)
grid.x = transpose(x); %(1, num_x) -> (num_x, 1)


y = double(python_Data_cell{2}); %python array -> double array. Shape (num_x, num_y)
grid.y_all = y(:,1); %We only require one column, (num_x,num_y) -> (1, num_y)


V = double(python_Data_cell{3}); %python array -> double array. Shape (1, num_V)
grid.V = transpose(V); %(1, num_V) -> (num_V, 1)


x_img = double(python_Data_cell{5}); %python array -> double array. Shape (1, num_x_img)
grid.x_img = transpose(x_img); %(1, num_x_img) -> (num_x_img, 1)


z_img = double(python_Data_cell{7}); %python array -> double array. Shape (num_x_img, num_y_img)
z_img = z_img* 1e-9; %Transforming back to original values
grid.z_img_all = permute(z_img, [2,1]);
% This section is to remove NaN values in a partial image. 
% Note this wasn't necessary for x or V since they're always full
grid.z_img = grid.z_img_all(:,all(~isnan(grid.z_img_all)));
grid.reduced_topo_size = size(grid.z_img,2);

y_img = double(python_Data_cell{6}); %python array -> double array. Shape (1, num_y_img)
grid.y_img_all = transpose(y_img); %(1, num_y_img) -> (num_y_img, 1)
grid.y_img = grid.y_img_all(1:grid.reduced_topo_size,1);



I = double(python_Data_cell{4}); %python array -> double array. Shape (num_x, num_y, num_V)
I = I * 1e-9; %Transforming back to original values
grid.I = permute(I, [3,1,2]); %to match matrix data orientation (num_x, num_y, num_V) -> (num_V, num_x, num_y)
% This section is to remove NaN values in a partial grid.
ratio = grid.reduced_topo_size/size(grid.y_img_all,1);
grid.reduced_grid_size = ceil(ratio*size(grid.y_all,1));
grid.y = grid.y_all(1:grid.reduced_grid_size,1);
grid.I = grid.I_all(:,:,1:grid.reduced_grid_size);


x_position_img = double(python_Data_cell{8});
grid.x_position_img = x_position_img;
y_position_img = double(python_Data_cell{9});
grid.y_position_img = y_position_img;

end
