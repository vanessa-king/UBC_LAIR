function [grid,comment] = load_grid_Matrix(folder, gridFileName, average_forward_and_backward, bias_direction)
% Description: loads Matrix-style grid data
%   Loads the files in either the upward or downward direction, to create "grid". 
%   Only one of upward or downward should be used. This code can handle a partial grid
% Parameters:
%   folder: folder to data
%   file: the filename of the data, including the extension
%   average_forward_and_backward: boolean, whether or not to average the
%   bias sweeps, or save them separate

arguments
    folder                   {mustBeFolder}
    gridFileName             {mustBeText}
    average_forward_and_backward = true
    bias_direction = 'forward'
end

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Never plot data (e.g. the whole grid) in the comment, only plot the values
%('=<VARn_value>') of variables that decide/affect how the function
%processes data (e.g. order of fit, ...) 
%Note convert all <VARn_value> to strings; 
comment = sprintf("load_grid_Matrix(folder=%s, gridFileName=%s, average_forward_and_backward=%s, bias_direction=%s)|", folder, gridFileName, mat2str(average_forward_and_backward), bias_direction);

%here the regular function 'begins' with data processing
%parse a FLAT-File and return its contents in a structure, and then transform the FLAT data into a matrix

flat = flat_parse([folder '/' gridFileName]);
matrix = flat2matrix(flat); % this is a 4-d matrix: I, V, x, and y

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

%check if forward and backward scans in y were done
if find(abs(diff(sign(diff(yraw))))) 
    %forward and backward scans were done. Only keep forward copy of the y values
    grid.y_all = yraw(1:length(yraw)/2);
    I_dbl = Itmp(:,:,1:length(yraw)/2);    
else %only forward was done
    grid.y_all = yraw;
    I_dbl = Itmp;
end

%check if forward and backward bias scans were done
if find(abs(diff(sign(diff(Vraw))))) 
    %forward and backward bias scans were done. Only keep forward copy of bias values
    NV = length(Vraw)/2; 
    grid.V = Vraw(1:NV);
    grid.I_all = (I_dbl(1:NV,:,:)+flip(I_dbl(NV+1:2*NV,:,:),1))/2; 
    if (~average_forward_and_backward) %if we want the sweeps separate
        grid.I_Forward_all = I_dbl(1:NV,:,:);
        grid.I_Backward_all = flip(I_dbl(NV+1:2*NV,:,:),1);
    end
else %only forward was done
    grid.V = Vraw;
    grid.I_all = I_dbl;
end

% This section is to remove NaN values from a partial grid. 

%ratio = grid.reduced_topo_size/size(grid.y_img_all,1);
%reduced_grid_size = ceil(ratio*size(grid.y_all,1));
%grid.y = grid.y_all(1:reduced_grid_size,1);
%grid.I = grid.I_all(:,:,1:reduced_grid_size);
%grid.I_Forward = grid.I_Forward_all(:,:,1:reduced_grid_size);
%grid.I_Backward = grid.I_Backward_all(:,:,1:reduced_grid_size);

end