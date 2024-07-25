function [header, par, I, dIdV, LockindIdV, bias, midV, QPI, LockinQPI] = load3dsall(fn, sigma)
% Description: 
%   loadsxmall modified Nanonis 3ds file loader
%   Reads a .3ds NANONIS file. Imports the header information into a struct,
%   all raw data into a (grid_dimension x grid dimension) cell array, where
%   each cell consists of a (points x 4) array, containing information on the
%   bias sweeps at each pixel for current, bias, and lock in data. A 5th
%   column is added to each cell array which consists of the Gaussian
%   filtered dIdV data and LockindIdV data. The Fourier transform of the dIdV/ LockindIdV data is taken, and
%   stored in QPI/ LockinQPI array.

% Input: 
%   fn: file name of the 3ds file(.3ds)
%   sigma: The order of the gaussian filtering we want to apply to the dIdV/LockindIdV data (int)
% Output: 
%   header: 1*1 file contains all the parameters/ notes in the 3ds file 
%   par: N-dim file with N being #parameters in the 3ds file
%   I: current (xsize*ysize*energy_slice matrix).
%   dIdV: numerical derivative of I 
%   LockindIdV: dIdV signal directly from Lockin amplifier, need to manually choose the channel(default as channel 1)
%   bias: bias at each energy slice (1*energy_slice array).
%   midV: average bias of 2 neighboring bias (1*energy_slice array).
%   QPI: 2D FFT of the dIdV.
%   LockinQPI: 2D FFT of the LockindIdV. 

%% "RESETS" MATLAB BEFORE RUNNING REST OF SCRIPT
close all;
clc;

%% DEFINE VARIABLES
header = ''; % Variable where header information is stored
par = '';
data = {}; % Raw data from .3ds file, stored in cell array
dIdV_data = {}; % Plottable dIdV data
LockindIdV_data = {}; % Plottable LockindIdV data
midV = []; % Vector containing midpoints of the voltage data, for plotting dIdV
QPI = {}; % Cell array for storing Fourier transformed (QPI) data
LockinQPI = {}; % Cell array for storing Fourier transformed (QPI) data

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
    
    %s1 = strsplit(s,'=');  % not defined in Matlab
    s1 = strsplit_i(s,'=');

    s_key = strrep(lower(s1{1}), ' ', '_');
    s_val = strrep(s1{2}, '"', '');
    
    switch s_key
    
    % dimension:
    case 'grid_dim'
        s_vals = strsplit_i(s_val, 'x');
        header.grid_dim = [str2num(s_vals{1}), str2num(s_vals{2})];
        
    % grid settings
    case 'grid_settings'
        header.grid_settings = sscanf(s_val, '%f;%f;%f;%f;%f');
         
    % fixed parameters, experiment parameters, channels:
    case {'fixed_parameters', 'experiment_parameters', 'channels'}
        s_vals = strsplit_i(s_val, ';');
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
        par = fread(fid, header.num_parameters, 'float'); % Reads some parameters which aren't useful for this code, but need to keep this in to correctly index through the binary file.
        data{i,j} = fread(fid, [header.points prod(size(header.channels))], 'float'); % Reads data
    end
end

x_num = header.grid_dim(1);
y_num = header.grid_dim(2);
points = header.points;

%% WRITES THE VOLTAGE TO A VECTOR
% In [mV]

bias = linspace(par(1),par(2),header.points);
bias = bias';

%% FINDS AVERAGE OFFSET VOLTAGE AND SUBTRACTS FROM THE VOLTAGE VECTOR
% voffset = zeros(x_num,y_num);
% for i = 1:y_num
%     for j = 1:x_num
%         voffset(i,j) = voltage_offset(data{i,j}(:,1),data{i,j}(:,2));
%     end
% end
% 
% voltage_offset_mean = mean(voffset(:));
% 
% voltage = voltage - voltage_offset_mean;

%% TAKES THE MIDPOINT OF THE VOLTAGE DATA 
% Since differentiation numerically reduces the overall number of points
% by 1, I take the midpoint to best represent the derivative data
midV = zeros(header.points-1,1);
for i = 1:(header.points-1)
    midV(i,1) = bias(i,1) + (bias(i+1,1) - bias(i,1))/2;
end

%% APPLY GAUSSIAN SMOOTHING TO THE CURRENT DATA
fprintf('Smoothing data \n')
I = zeros(x_num,y_num,points);
for i = 1:x_num
    for j =1:y_num
         I(i,j,:) = gaussfilter1d(data{i,j}(:,1),sigma); % See function for more info here
    end
end
%% APPLY GAUSSIAN SMOOTHING TO THE LOCKIN DATA
fprintf('Aquiring Lockin data and apply gaussian smooth \n')
LockindIdV = zeros(x_num,y_num,points);
for i = 1:x_num
    for j =1:y_num
         LockindIdV(i,j,:) = gaussfilter1d(data{i,j}(:,1),sigma); % Make sure to check which channel is Lockin signal sitting 
    end
end

%% NUMERICALLY DIFFERENTIATE THE CURRENT DATA TO OBTAIN dIdV
fprintf('Differentiating current \n')
dIdV = zeros(x_num,y_num,points - 1);
for i = 1:x_num
    for j =1:y_num
         dIdV(i,j,:) = diff(I(i,j,:));
    end
end

%% TAKE FOURIER TRANSFORM OF THE dIdV DATA
% 1. Subract the mean to remove the zero frequency spike
% 2. 2D fast Fourier transform using the FFT2 function
% 3. Shift the FFT2 result so zero frequency is at the center
% 4. Take modulus for plotting the intensity


fprintf('Fourier transforming dIdV \n')
QPI = zeros(x_num,y_num,points-1);
for i = 1:(points - 1)
    QPI(:,:,i) = abs(fftshift(fft2(dIdV(:,:,i) - mean(mean(dIdV(:,:,i))))));
end

%% TAKE FOURIER TRANSFORM OF THE LOCKIN dIdV DATA
% 1. Subract the mean to remove the zero frequency spike
% 2. 2D fast Fourier transform using the FFT2 function
% 3. Shift the FFT2 result so zero frequency is at the center
% 4. Take modulus for plotting the intensity


fprintf('Fourier transforming LockindIdV \n')
LockinQPI = zeros(x_num,y_num,points);
for i = 1:(points)
    LockinQPI(:,:,i) = abs(fftshift(fft2(LockindIdV(:,:,i) - mean(mean(LockindIdV(:,:,i))))));
end

fprintf('Finished! \n')

fclose(fid);

end  % of function load3dsall


function s = strsplit_i(str, del)
    s = {};
    while ~isempty(str),
        [t,str] = strtok(str, del);
        s{end+1} = t;
    end
end