% Description: 
%   Wrapper function for loading topos from Nanonis, using the Nanonis-made
%   loadsxm.m function, processes the data into a structure 
% Input: 
%   folder: string of folder containing data
%   stamp_project: the filename leader, takes the form 'yyyymmdd-XXXXXX_CaPt--STM_Spectroscopy--'
%   topo_number: string of sxm file number, ie: 'NbIrPtTe001'
% Output: 
%   topo: structure containing all the topo associated data
%   comment: string containing log comment

function [topo, comment] = load_topo_Nanonis(folder, stamp_project, topo_number)

arguments
    folder          {mustBeText}
    stamp_project   {mustBeText}
    topo_number     {mustBeText}
end

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Never plot data (e.g. the whole gird) in the comment, only plot the values
%('=<VARn_value>') of variables that decide/affect how the function
%processes data (e.g. order of fit, ...) 
%Note convert all <VARn_value> to strings; 
comment = sprintf("load_topo_Nanonis(folder=%s, stamp_project=%s, topo_number=%s)|", folder, stamp_project, topo_number);

%regular function processing:

topoFileName = strcat(folder,"/",stamp_project,topo_number,".sxm");
%load the raw sxm data:
[header, data] = loadsxm(topoFileName,1);

%Return the entire header, in case we need it
topo.header = header;

topo.data = data;

end