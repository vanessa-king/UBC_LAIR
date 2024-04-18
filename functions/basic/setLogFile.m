function [LOGpath,LOGfile] = setLogFile(fileBool)
%UI to select file / directory + set name for LOGpath and LOGfile 
%   User input via UI to select a folder (file). If no file is picked the
%   user is prompted to set a file name which is set to be unique via
%   appending a running number. The optional variable 
arguments
    fileBool logical =0
end

    if fileBool == 0
        %uigetdir + name prompt
        LOGpath = uigetdir();
        LOGfile = uniqueNamePrompt('ProjectLogFile','',LOGpath);
        

    elseif fileBool == 1
        %uigetfile sets the name
        [LOGpath,LOGfile,~] = selectData();
    end

end