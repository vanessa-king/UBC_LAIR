function [LOGcomment] = logUsedBlocks(LOGpath, LOGfile, block, LOGcomment ,initialize)
%Logging blocks used in the UBC_LAIR main script. 
%   The function creates and updates a .txt file that logs all the blocks
%   that were executed in the in the script with a time stamp.
%   
%   LOGpath     * path variable to the location of the log file
%   LOGfile     * file name 
%   block       unique block identifier (should be 5 charcters)
%   comment     free comment to be logged (e.g. list of parameters used in 
%               the functions executed within the corresponding block) 
%   initialize  1 = yes, 0 = no 
%
%   * note that the strings LOGfile name and LOGpath should correspond to
%   the char [file path] returned by uigetfile() for a data file. 

 

arguments
    LOGpath     {mustBeText}    %string
    LOGfile     {mustBeText}    %string
    block       {mustBeText}    %string
    LOGcomment  {mustBeText}    %string
    initialize  {mustBeNumericOrLogical} = 0
end

% open or create file and write header in the initialization run
% clears the log file!
if initialize == 1
    fid = fopen(strcat(LOGpath, '/',LOGfile,'_LOGfile.txt'),'w+');
    %header = 'DATE                  BLOCK   COMMENT';
    fprintf(fid,'%21s %7s %s\r\n','DATE and TIME        ','BLOCK  ','COMMENT');
    initialize = 0;
    fclose(fid);
end

% append timestamp and executed block to the log file
if initialize == 0
    fid = fopen(strcat(LOGpath, '/',LOGfile,'_LOGfile.txt'),'a+');
    t = datetime;
    dtstr = string(t);
    M=convertStringsToChars(strcat(dtstr, "  ",block, "   ",LOGcomment));
    fprintf(fid,'%s\r\n',M);
    fclose(fid);
end

%resets LOGcomment so the next block doesn't accidently carry over an old
%string. 
LOGcomment = "";
end