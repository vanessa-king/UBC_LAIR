% Description: 
%   Wrapper function for loading topos from Nanonis, using the Nanonis-made
%   loadsxm.m function, processes the data into a structure 
% Input: 
%   folder: string of folder containing data
%   stamp_project: the filename leader, takes the form 'yyyymmdd-XXXXXX_CaPt--STM_Spectroscopy--'
%   topo_number: string of sxm file number, ie: 'NbIrPtTe001'
%   direction: string indicating what topo you want: 
%   "forward" or "backward" 
% Output: 
%   topo: structure containing all the topo associated data
%   comment: string containing log comment

function [topo, comment] = load_topo_Nanonis(folder, topoFileName, direction)

arguments
    folder          {mustBeText}
    topoFileName    {mustBeText}
    direction       {mustBeText} = "forward"
end

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Never plot data (e.g. the whole gird) in the comment, only plot the values
%('=<VARn_value>') of variables that decide/affect how the function
%processes data (e.g. order of fit, ...) 
%Note convert all <VARn_value> to strings; 
comment = sprintf("load_topo_Nanonis(folder=%s, topoFileName=%s, direction=%s)|", folder, topoFileName,direction);

%regular function processing:

loadStr = strcat(folder,'/',topoFileName);
%load the raw sxm data:
if direction == "forward"
    [header, data] = loadsxm(loadStr,1);
elseif direction == "backward"
    [header, data] = loadsxm(loadStr,2);
else
    fprintf('Invalid direction input.\n');
    return
end

%Return the entire header, in case we need it
topo.header = header;

%Calculate the x and y values from the header
x_range = header.scan_range(1); %in m
y_range = header.scan_range(2); %in m
x_range = x_range * 1e9; %convert m to nm
y_range = y_range * 1e9; %convert m to nm
x_resolution = header.scan_pixels(1);
y_resolution = header.scan_pixels(2);
topo.x = linspace((-x_range/2.0), (x_range/2), x_resolution);
topo.y_all = linspace((-y_range/2.0), (y_range/2.0), y_resolution);

%Get the center position of the topo (in m)
topo.x_position = header.scan_offset(1);
topo.y_position = header.scan_offset(2);

%Get the z data. It doesn't come in the correct orientation relative,
% so we need to rotate it 270 deg CCW (90 deg CW)
topo.z_all = rot90(data,3);

%This section is to determine if we have a partial image and remove NaN
%values if so. Note that this wasn't necessary for x since it's always full

%find pixels where there is data
[x_coordinates, y_coordinates] = find(~isnan(topo.z_all));

%check if the topo is finished 
if max(y_coordinates) == max(x_coordinates) %full topo
    topo.y = topo.y_all;
    topo.z = topo.z_all;

else % unfinished topo
    %assign topo.y and topo.z
    topo.y = topo.y_all(:, 1:max(y_coordinates)-1);
    topo.z = topo.z_all(:, 1:max(y_coordinates)-1);
end


end