function [filePath,fileName,ext] = selectData()
%UI based selection of data file
%   UI prompt to select data. The filePath, fileName, and it's extension 
%   are returend. 
%   If uigetfile is aborted, retuns [0, 0, 0]

%   Markus Altthaler

    [tempFile,filePath] = uigetfile('*.*','Select data');
    if tempFile==0
        %uigetfile abort case
        ext = 0;
    else
        %regular case 
        [~, fileName, ext] = fileparts(tempFile);
    end
end