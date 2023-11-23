function [data, comment] = specLoad(spec)
%This function loads spectrum. 
arguments 
    spec
end

comment = sprintf("specLoad(spec=%s)|", spec);

filename = spec;
% Read the file as a table
opts = detectImportOptions(filename, 'Delimiter', '\t');
data = readtable(filename, opts);

end