function [dataCalled] = ifIsEmptyField(data,dataset,varNameIn)
%checks if a field exists and returns [] for empty fields
%   Helper function for maintrunk to allow varNameIn = [] calls for data.(<dataset>).(<varNamein>) 

arguments
    data
    dataset     {mustBeText}
    varNameIn   %no must be text to handle [] input
end

if isempty(varNameIn)
    %parse [] to output
    dataCalled = [];
elseif isfield(data,dataset)
    %check for dataset
    if isfield(data.(dataset),(varNameIn))  
        %check for specific variable
        dataCalled = data.(dataset).(varNameIn);
    else 
        error("data.%s.%s does not exist!", dataset, mat2str(varNameIn));
    end
else
    error("data.%s does not exist!", dataset);
end