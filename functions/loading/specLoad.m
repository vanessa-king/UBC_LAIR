function [data, comment] = specLoad(folder, stamp_project, spectra_number)
%This function loads spectrum. 
arguments 
    folder
    stamp_project
    spectra_number
end

comment = sprintf("specLoad(folder=%s, stamp_project=%s, spectra_number=%s)|", folder, stamp_project, spectra_number);

specfileName = strcat(folder,"/",stamp_project,spectra_number,".dat");

% Read the file as a table
opts = detectImportOptions(specfileName, 'Delimiter', '\t');
data = readtable(specfileName, opts);

end