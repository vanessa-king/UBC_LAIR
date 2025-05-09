function grid = load_grid_Nanonis(folder,gridFileName)
%Wrapper function for loading grids from Nanonis
%   Uses the Nanonis-made load3ds.m function, processes the data into a structure 
% Input: 
%   folder: string of folder containing data
%   stamp_project: the filename leader, takes the form 'yyyymmdd-XXXXXX_CaPt--STM_Spectroscopy--'
%   grid_number: string of 3ds file number, ie: 'NbIrPtTe001'
% Output: 
%   grid: structure containing all the grid associated data
%   comment: string containing log comment
arguments
    folder          {mustBeText}
    gridFileName    {mustBeText}
end

%regular function processing:

%load the raw 3ds data:
[header, par, data] = load3ds_Nanonis(strcat(folder,'/',gridFileName));

%Return the entire header, in case we need it
grid.header = header;

%Calculate the x and y values from the header
%Get x_position and y_position (in m) off of parameters in the header:
grid.x_position = header.grid_settings(1); 
grid.y_position = header.grid_settings(2); 
x_range = header.grid_settings(3);%in m
y_range = header.grid_settings(4);%in m
x_range = x_range * 1e9; %convert m to nm
y_range = y_range * 1e9; %convert m to nm
number_x_points = header.grid_dim(1);
number_y_points = header.grid_dim(2);

%Get x out of the experimental parameters:
grid.x = transpose(linspace((-x_range/2.0), (x_range/2.0), number_x_points));

%Get y out of the experimental parameters:
if par{1,1}(4) < grid.y_position %y direction is up
    y_all = transpose(linspace((-y_range/2.0), (y_range/2.0), number_y_points));
elseif par{1,1}(4) > grid.y_position %y direction is down
    y_all = transpose(linspace((y_range/2.0), (-y_range/2.0), number_y_points));
else
    fprintf('Invalid scan direction in header.\n');
    return
end

%Calculate V based off of parameters in the header:
bias_start = par{1,1}(1);
bias_end = par{1,1}(2);
number_bias_points = header.points;
grid.V = transpose(linspace(bias_start,bias_end,number_bias_points));

%Get the channels from the data: 
I_all = zeros(number_x_points, number_y_points, number_bias_points);
lock_in_all = zeros(number_x_points, number_y_points, number_bias_points);
I_backward_all = zeros(number_x_points, number_y_points, number_bias_points);
z_all = zeros(number_x_points, number_y_points, number_bias_points);
z_backward_all = zeros(number_x_points, number_y_points, number_bias_points);
other_channel_all = zeros(number_x_points, number_y_points, number_bias_points);

for x = 1:number_x_points
    for y = 1:number_y_points
        for channel = 1:size(data{x,y},2)
            if header.channels{channel} == "Current (A)"
                I_all(x,y,:) = data{x,y}(:,channel); %Note: I_all is the forward scan by default
            elseif header.channels{channel} == "LI D1 X 1 omega (A)"
                lock_in_all(x,y,:) = data{x,y}(:,channel);
            elseif header.channels{channel} == "Current [bwd] (A)"
                I_backward_all(x,y,:) = data{x,y}(:,channel);
            elseif header.channels{channel} == "Z (m)"
                z_all(x,y,:) = data{x,y}(:,channel);
            elseif header.channels{channel} == "Z [bwd] (m)"
                z_backward_all(x,y,:) = data{x,y}(:,channel);
            else
                other_channel_all(x,y,:) = data{x,y}(:,channel);
            end
        end
    end
end

%The energy dimension of z is reductive, removing it:
z_all = z_all(:,:,1);
z_backward_all = z_backward_all(:,:,1);


% This section is to determine if we have a partial image and remove 0 values if so. 
% Note this wasn't necessary for x or V since they're always full
[x_coordinates,y_coordinates] = find(all(I_all,3)); %pixels where there are spectra

%Check if the grid is finished, assign variables accordingly
if all(I_all,'all') %grid is finished
    grid.I = I_all;
    if any(lock_in_all,'all')
        grid.lock_in = lock_in_all;
    end
    if any(I_backward_all,'all')
        grid.I_backward = I_backward_all;
    end
    if any(z_all,'all')
        grid.z = z_all;
        %Convert from m to nm
        grid.z = grid.z .* 1e9;
    end
    if any(z_backward_all,'all')
        grid.z_backward = z_backward_all;
        %Convert from m to nm
        grid.z_backward = grid.z_backward .* 1e9;
    end
    if any(other_channel_all,'all')
        grid.other_channel = other_channel_all;
    end
    
    %Assign y:
    grid.y = y_all;

else  %grid is not finished, take off the any unfinished fast scan line
    grid.I_all = I_all;
    grid.I = grid.I_all(:, 1:max(y_coordinates)-1 ,:);

    if any(lock_in_all,'all')
        grid.lock_in_all = lock_in_all;
        grid.lock_in = grid.lock_in_all(:, 1:max(y_coordinates)-1, :);
    end

    if any(I_backward_all,'all')
        grid.I_backward_all = I_backward_all;
        grid.I_backward = grid.I_backward_all(:, 1:max(y_coordinates)-1, :);
    end

    if any(z_all,'all')
        grid.z_all = z_all;
        grid.z = grid.z_all(:, 1:max(y_coordinates)-1);
        %Convert from m to nm
        grid.z_all = grid.z_all .* 1e9;
        grid.z = grid.z .* 1e9;
    end
    
    if any(z_backward_all,'all')
        grid.z_backward_all = z_backward_all;
        grid.z_backward = grid.z_backward_all(:, 1:max(y_coordinates)-1);
        %Convert from m to nm
        grid.z_backward_all = grid.z_backward_all .* 1e9;
        grid.z_backward = grid.z_backward .* 1e9;
    end

    if any(other_channel_all,'all')
        grid.other_channel_all = other_channel_all;
        grid.other_channel = grid.other_channel_all(:, 1:max(y_coordinates)-1, :);
    end

    %Assign y:
    grid.y_all = y_all;
    grid.y = grid.y_all(1:max(y_coordinates)-1);

end

end


function [header, par, data] = load3ds_Nanonis(fn)
% Description: 
%   Reads a .3ds NANONIS file. Imports the header information into a struct,
%   all raw data into a (grid_dimension x grid dimension) cell array, where
%   each cell consists of a (points x 4) array, containing information on the
%   bias sweeps at each pixel for current, bias, and lock in data. A 5th
%   column is added to each cell array which consists of the Gaussian
%   filtered dIdV data and LockindIdV data. The Fourier transform of the dIdV/ LockindIdV data is taken, and
%   stored in QPI/ LockinQPI array.

% Input: 
%   fn: file name of the 3ds file(.3ds)
% Output: 
%   header: 1*1 file contains all the parameters/ notes in the 3ds file 
%   par: N-dim file with N being #parameters in the 3ds file
%   data: full set of data from 3ds file
%% DEFINE VARIABLES
header = ''; % Variable where header information is stored
par = '';
data = {}; % Raw data from .3ds file, stored in cell array

%% FIND AND OPEN .3ds FILE
if exist(fn, 'file')
    fid = fopen(fn, 'r', 'ieee-be');    % open with big-endian
else
    fprintf('File does not exist.\n');
    return;
end

%% READ THE HEADER DATA
% The header consists of key-value pairs, separated by an equal sign,
% e.g. Grid dim="64 x 64". If the value contains spaces it is enclosed by
% double quotes (").
while 1
    s = strtrim(fgetl(fid));
    if strcmp(upper(s),':HEADER_END:')
        break
    end
    
    s1 = strsplit(s,'=');  % not defined in Matlab
    %s1 = strsplit_i(s,'=');

    s_key = strrep(lower(s1{1}), ' ', '_');
    s_val = strrep(s1{2}, '"', '');
    
    switch s_key
    
    % dimension:
    case 'grid_dim'
        s_vals = strsplit(s_val, 'x');
        %s_vals = strsplit_i(s_val, 'x');
        header.grid_dim = [str2num(s_vals{1}), str2num(s_vals{2})];
        
    % grid settings
    case 'grid_settings'
        header.grid_settings = sscanf(s_val, '%f;%f;%f;%f;%f');
         
    % fixed parameters, experiment parameters, channels:
    case {'fixed_parameters', 'experiment_parameters', 'channels'}
        s_vals = strsplit(s_val, ';');
        %s_vals = strsplit_i(s_val, ';');
        header.(s_key) = s_vals;
        
    % number of parameters
    case '#_parameters_(4_byte)'
        header.num_parameters = str2num(s_val);
        
    % experiment size
    case 'experiment_size_(bytes)'
        header.experiment_size = str2num(s_val);

    % spectroscopy points
    case 'points'
        header.points = str2num(s_val);

    % delay before measuring
    case 'delay_before_measuring_(s)'
        header.delay_before_meas = str2num(s_val);
    
    % other parameters -> treat as strings
    otherwise
        s_key = regexprep(s_key, '[^a-z0-9_]', '_');
        header.(s_key) = s_val;
    end
end

%% READS THE DATA FROM THE .3ds FILE INTO A CELL ARRAY
fprintf('Reading data \n')

for j = 1:header.grid_dim(2) % Size of the grid in the y-direction
    for i = 1:header.grid_dim(1) % Size of the grid in the x-direction
        par{i,j} = fread(fid, header.num_parameters, 'float'); % Reads the parameters
        data{i,j} = fread(fid, [header.points prod(size(header.channels))], 'float'); % Reads data
    end
end
end