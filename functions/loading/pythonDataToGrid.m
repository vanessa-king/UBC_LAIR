% Requirements:
% Matlab 2021B or newer - 'pyrunfile' does not exist in older versions
% python 3.8 or newer. Type 'pyenv' in Matlab to see which python version Matlab recognizes

% Description:
% Reads Nanonis python-processed gridmap data and returns as grid structure
% Input: gridFileName = string of full path and 3ds file name, ie: '/Users/vanessa/Desktop/UBC/Lab/Generic_Data_Processing_Code/Grid_Spectroscopy--NbIrPtTe001.3ds'
%        topoFileName = string of full path and sxm file name, ie: '/Users/vanessa/Desktop/UBC/Lab/Generic_Data_Processing_Code/NbIrTe4-0012.sxm'
%        topoDirection = string of desired topo z scan direction, either
%        'forward' or 'backward'
% Output:grid = 1x1 structure containing x,y,I,V,x_img,y_img,z_img

function [grid, comment] = pythonDataToGrid(gridFileName, topoFileName, topoDirection)

arguments
    gridFileName    {mustBeText}
    topoFileName    {mustBeText}
    topoDirection   {mustBeText}
end

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Never plot data (e.g. the whole gird) in the comment, only plot the values
%('=<VARn_value>') of variables that decide/affect how the function
%processes data (e.g. order of fit, ...) 
%Note convert all <VARn_value> to strings; 
comment = sprintf("pythonDataToGrid(gridFileName=%s, topoFileName=%s, topoDirection=%s)|", gridFileName, topoFileName, topoDirection);

%regular function processing:

pythonScript_and_fileName = strcat("read_grid_data.py ",gridFileName, " ",topoFileName, " ", topoDirection);

python_Data = pyrunfile(pythonScript_and_fileName, "gridArrays"); %Calls pythonScript, gives the file names as input, gets gridArrays as output

python_Data_cell = cell(python_Data); %Turning from python List to cell array that contains python arrays


x = double(python_Data_cell{1}); %python array -> double array. Shape (num_x, num_y)
x = x(1,:);%We only require one row, (num_x, num_y) -> (num_x,1)
grid.x = transpose(x); %(1, num_x) -> (num_x, 1)


y = double(python_Data_cell{2}); %python array -> double array. Shape (num_x, num_y)
grid.y = y(:,1); %We only require one column, (num_x,num_y) -> (1, num_y)


V = double(python_Data_cell{3}); %python array -> double array. Shape (1, num_V)
grid.V = transpose(V); %(1, num_V) -> (num_V, 1)


I = double(python_Data_cell{4}); %python array -> double array. Shape (num_x, num_y, num_V)
I = I * 1e-9; %Transforming back to original values
grid.I = permute(I, [3,1,2]); %to match matrix data orientation (num_x, num_y, num_V) -> (num_V, num_x, num_y)

x_img = double(python_Data_cell{5}); %python array -> double array. Shape (1, num_x_img)
grid.x_img = transpose(x_img); %(1, num_x_img) -> (num_x_img, 1)

y_img = double(python_Data_cell{6}); %python array -> double array. Shape (1, num_y_img)
grid.y_img = transpose(y_img); %(1, num_y_img) -> (num_y_img, 1)

z_img = double(python_Data_cell{7}); %python array -> double array. Shape (num_x_img, num_y_img)
z_img = z_img* 1e-9; %Transforming back to original values
grid.z_img = z_img;


end
