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

function [topo, comment] = load_topo_Nanonis(folder, stamp_project, topo_number, direction)

arguments
    folder          {mustBeText}
    stamp_project   {mustBeText}
    topo_number     {mustBeText}
    direction       {mustBeText}
end

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Never plot data (e.g. the whole gird) in the comment, only plot the values
%('=<VARn_value>') of variables that decide/affect how the function
%processes data (e.g. order of fit, ...) 
%Note convert all <VARn_value> to strings; 
comment = sprintf("load_topo_Nanonis(folder=%s, stamp_project=%s, topo_number=%s, direction=%s)|", folder, stamp_project, topo_number,direction);

%regular function processing:

topoFileName = strcat(folder,"/",stamp_project,topo_number,".sxm");

%load the raw sxm data:
if direction == "forward"
    [header, data] = loadsxm(topoFileName,1);
elseif direction == "backward"
    [header, data] = loadsxm(topoFileName,2);
else
    fprintf('Invalid direction input.\n');
    return
end

%Return the entire header, in case we need it
topo.header = header;

%Calculate the x and y values from the header
[x_range, y_range] = header.scan_range; %in m
x_range = x_range * 1e9; %convert m to nm
y_range = y_range * 1e9; %convert m to nm
[x_resolution, y_resolution] = header.scan_pixels;
topo.x = linspace((-x_range/2.0), (x_range/2), x_resolution);
topo.y_all = linspace((-y_range/2.0), (y_range/2.0), y_resolution);

%Get the center position of the topo (in m)
[topo.x_position, topo.y_position] = header.scan_offset;

%Get the z data
topo.z_all = data;

%Deal with partial/non-square topos:


end