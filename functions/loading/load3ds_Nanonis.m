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

function [header, par, data] = load3ds_Nanonis(fn)
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

for j = 1:header.grid_dim(1) % Size of the grid in the y-direction
    for i = 1:header.grid_dim(2) % Size of the grid in the x-direction
        par{i,j} = fread(fid, header.num_parameters, 'float'); % Reads the parameters
        data{i,j} = fread(fid, [header.points prod(size(header.channels))], 'float'); % Reads data
    end
end