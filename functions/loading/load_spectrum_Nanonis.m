function [spectrum,comment] = load_spectrum_Nanonis(folder,spectrumFileName)
%Wrapper load function for point spectrum '.dat' files
%   Uses specLoad.m function, processes the data into a structure 
% Input: 
%   folder: string of folder containing data
%   spectrumFileName: the filename, including the extension
% Output: 
%   spectrum: structure containing all the point spectrum associated data
%   comment: string containing log comment

arguments
    folder              {mustBeText}
    spectrumFileName    {mustBeText}
end

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Never plot data (e.g. the whole gird) in the comment, only plot the values
%('=<VARn_value>') of variables that decide/affect how the function
%processes data (e.g. order of fit, ...) 
%Note convert all <VARn_value> to strings; 
comment = sprintf("load_spectrum_Nanonis(folder=%s, spectrumFileName=%s)|", folder, spectrumFileName);

%regular function processing:

%load the raw dat data:
[header, channels, data] = specLoad(strcat(folder,'/',spectrumFileName));

%Return the entire header, in case we need it
spectrum.header = header;
spectrum.header.channels = channels;

%Get the channels from the data: 
number_channels = size(data,1);
for channel = 1:number_channels
    if spectrum.header.channels{channel} == "Current (A)"
        spectrum.I = data(channel,:);
    elseif spectrum.header.channels{channel} == "Bias calc (V)"
        spectrum.V = data(channel,:);
    elseif spectrum.header.channels{channel} == "LI Demod 1 X (A)"
        spectrum.lock_in_x = data(channel,:);
    elseif spectrum.header.channels{channel} == "LI Demod 1 Y (A)"
        spectrum.lock_in_y = data(channel,:);
    else
        disp(strcat("Not saving channel ", spectrum.header.channels{channel}));
    end
end


end