function [dataOut] = ifIsEmptyField(data,dataset,varNameIn)
%checks if a field exists and returns [] for empty fields
%   Helper function for maintrunk to allow varNameIn = [] calls for data.(<dataset>).(<varNamein>) 

% created by: M. Altthaler, 2025-03

arguments
    data
    dataset     {mustBeText}
    varNameIn   %no must be text to handle [] input
end

if isempty(varNameIn)
    %parse [] to output
    dataOut = [];
else
    dataOut = nestedStructCall(data,dataset,varInString);
end