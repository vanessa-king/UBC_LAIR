function [spectrum,comment] = load_spectrum_Nanonis(folder,spectrumFileName,direction)
% Load function for point spectrum '.dat' files
% Description: 
%   Wrapper function for loading point spectra from Nanonis, using 
%   specLoad.m function, processes the data into a structure 
% Input: 
%   folder: string of folder containing data
%   spectrum_number: the filename, including the extension
%   direction: string indicating what energy scan direction you want: 
%   "forward" or "backward" 
% Output: 
%   spectrum: structure containing all the point spectrum associated data
%   comment: string containing log comment

arguments
    folder          {mustBeText}
    spectrumFileName    {mustBeText}
    direction       {mustBeText} = "forward"
end

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Never plot data (e.g. the whole gird) in the comment, only plot the values
%('=<VARn_value>') of variables that decide/affect how the function
%processes data (e.g. order of fit, ...) 
%Note convert all <VARn_value> to strings; 
comment = sprintf("load_spectrum_Nanonis(folder=%s, spectrumFileName=%s, direction=%s)|", folder, spectrumFileName,direction);

%regular function processing:

loadStr = strcat(folder,'/',spectrumFileName);
%load the raw dat data:
if direction == "forward"
    [header, z_all] = specLoad(loadStr,2);
elseif direction == "backward"
    [header, z_all] = specLoad(loadStr,1);
else
    fprintf('Invalid direction input.\n');
    return
end


spectrum = inputArg2;
end