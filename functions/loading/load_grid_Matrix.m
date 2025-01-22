function [grid, grid_topo,comment] = load_grid_Matrix(folder, gridFileName)
% Description: loads Matrix-style grid data
%   VK - Jan 2025
%   Loads the files in either the upward or downward direction, to create "grid". 
%   Only one of upward or downward should be used. This code can handle a partial grid
% Parameters:
%   folder: folder to data
%   gridFileName: the filename of the data, including the extension


arguments
    folder                   {mustBeFolder}
    gridFileName             {mustBeText}
end

%regular function processing:

addpath(folder)
flat = flat_parse(gridFileName);
grid.header = rmfield(flat, 'phys_data'); %define header as everything but the data
[matrix, matrix_header] = flat2matrix(flat); % this is a 4-d matrix: I, V, x, and y
grid.header.matrix_header = matrix_header; %add header defined in flat2matrix
rmpath(folder);

Iraw = matrix{1}; % matrix is 4-dimensional
Vraw = matrix{2};
%convert x,y values in m to nm:
xraw = 1e9*matrix{3};
yraw = 1e9*matrix{4};

%check if forward and backward scans in x were done
if find(abs(diff(sign(diff(xraw))))) 
    %forward and backward scans were done. Only keep forward copy of the x values
    grid.x = xraw(1:length(xraw)/2);
    Itmp = Iraw(:,1:length(xraw)/2,:);                                 
else %only forward was done
    grid.x = xraw;
    Itmp = Iraw;
end

%check if up and down scans were done
if find(abs(diff(sign(diff(yraw))))) 
    %up and down scans were done. Only keep forward copy of the y values
    grid.y_all = yraw(1:length(yraw)/2);
    I_dbl = Itmp(:,:,1:length(yraw)/2);    
else %only forward was done
    grid.y_all = yraw;
    I_dbl = Itmp;
end

%check if forward and backward bias scans were done
if find(abs(diff(sign(diff(Vraw))))) 
    %forward and backward bias scans were done
    NV = length(Vraw)/2; 
    grid.V = Vraw(1:NV);
    grid.I_all = I_dbl(1:NV,:,:);
    grid.I_backward_all = flip(I_dbl(NV+1:2*NV,:,:),1);
else %only forward was done
    grid.V = Vraw;
    grid.I_all = I_dbl;
end

% This section is to remove NaN values from a partial grid. 

%ratio = grid.reduced_topo_size/size(topo.y_all,1);
%reduced_grid_size = ceil(ratio*size(grid.y_all,1));
%grid.y = grid.y_all(1:reduced_grid_size,1);k
%grid.I = grid.I_all(:,:,1:reduced_grid_size);
%grid.I_Forward = grid.I_Forward_all(:,:,1:reduced_grid_size);
%grid.I_Backward = grid.I_Backward_all(:,:,1:reduced_grid_size);

%%% Corresponding Topo
%select data via UI
[filePath, fileName, fileExt] = selectData();
topoFileName = strcat(fileName, fileExt);
%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
comment = sprintf("load_grid_Matrix(folder=%s, topoFileName=%s)|", filePath, topoFileName);
%Now, load the corresponding topo
grid_topo = load_topo_Matrix(filePath, topoFileName);

end
