function [LOGpath,LOGfile] = setLogFile(fileBool)
%UI to select file / directory + set name for LOGpath and LOGfile 
%   User input via UI to select a file (folder). If no file is picked the
%   user is prompted to set a file name, which is set to be unique via
%   appending a running number. The optional variable fileBool defines if a
%   file is chosen or a folder. It defaults to chosing a folder.
arguments
    fileBool logical =0
end

    if fileBool == 0
        %uigetdir + name prompt
        LOGpath = uigetdir();
        LOGfile = uniqueLOGNamePrompt(LOGpath,'NewProject');
    elseif fileBool == 1
        %uigetfile sets the name
        [LOGpath,LOGfile,~] = selectData();
    end

end