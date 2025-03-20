function [filePath,fileName,ext] = selectData()
%UI based selection of data file
%   UI prompt to select data. The filePath, fileName, and it's extension 
%   are returend. 

%   Markus Altthaler

[tempFile,filePath] = uigetfile('*.*','Select data');
[~, fileName, ext] = fileparts(tempFile);
end