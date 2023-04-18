function [status,message,messageId] = saveUsedBlocksLog(LOGpath, LOGfile, SAVEpath, SAVEfile)
%copies the current state of the master log file to the specified location
%   Whenever data is saved by executing a block in the UBC_LAIR script, this function
%   must be used to save a copy of the master log file at the corresponding
%   loction, which contains all blocks executed up to that point. 
%
%   LOGpath     path master log file (same as for logUsedBlocks!)
%   LOGfile     file name master log file (same as for logUsedBlocks!)
%   SAVEpath    path to the saved data/figure/... 
%   SAVEfile    file name of the saved data/figure/... (note _LOGfile is
%               added automatically)

arguments
    LOGpath     {mustBeText}
    LOGfile     {mustBeText}
    SAVEpath    {mustBeText}
    SAVEfile    {mustBeText}
end

% a copy of the master LOGfile is created in the specified location 
[status,message,messageId] = copyfile(strcat(LOGpath,'\',LOGfile,'_LOGfile.txt'),strcat(SAVEpath,'\',SAVEfile,'_LOGfile.txt'), 'f');

end