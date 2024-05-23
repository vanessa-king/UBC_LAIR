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
    [header, z_all] = loadsxm(loadStr,2);
elseif direction == "backward"
    [header, z_all] = loadsxm(loadStr,1);
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
number_x_points = header.scan_pixels(1);
number_y_points = header.scan_pixels(2);
topo.x = transpose(linspace((-x_range/2.0), (x_range/2.0), number_x_points));
if topo.header.scan_dir == "up" %y direction is positive
    y_all = transpose(linspace((-y_range/2.0), (y_range/2.0), number_y_points));
elseif topo.header.scan_dir == "down" %y direction is negative
    y_all = transpose(linspace((y_range/2.0), (-y_range/2.0), number_y_points));
else
    fprintf('Invalid scan direction in header.\n');
    return
end


%Get the center position of the topo (in m)
topo.x_position = header.scan_offset(1);
topo.y_position = header.scan_offset(2);

%This section is to determine if we have a partial image and remove NaN
%values if so. Note that this wasn't necessary for x since it's always full

%find pixels where there is data
[x_coordinates, y_coordinates] = find(~isnan(z_all));

%assign topo.y and topo.z:
%first check if the topo is finished 
if ~any(isnan(z_all),'all') %we have a full topo
    topo.y = y_all;
    topo.z = z_all;

else % unfinished topo
    topo.y_all = y_all;
    topo.z_all = z_all;
    topo.y = topo.y_all(:, 1:max(y_coordinates)-1);
    topo.z = topo.z_all(:, 1:max(y_coordinates)-1);
end


end