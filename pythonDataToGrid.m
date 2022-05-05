% Requirements:
% Matlab 2021B or newer - 'pyrunfile' does not exist in older versions
% python 3.8 or 3.9. Type 'pyenv' in Matlab to see which python version Matlab recognizes

% Description:
%  Reads Nanonis python-processed gridmap data and returns as grid structure
% Parameters 
%   Input: fileName = string of full path and 3ds file name, ie: '/Users/vanessa/Desktop/UBC/Lab/Generic_Data_Processing_Code/Grid_Spectroscopy--NbIrPtTe001.3ds'
%             *Note: because this file is being read in a python script, the filename MUST NOT have spaces
%   Output: grid = structure containing x, y, V, I gridmap data, same format as output of gridLoadData()


function grid = pythonDataToGrid(fileName)

pythonScript_and_fileName = strcat("read_grid_data.py ",fileName); % combines the name of python script to run and the filename

python_Data = pyrunfile(pythonScript_and_fileName, "gridArrays"); %Calls pythonScript, gives fileName as input, gets gridArrays as output

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

end
