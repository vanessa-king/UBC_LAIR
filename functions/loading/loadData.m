function [data, commentA, commentB, commentC, logC] = loadData(data)
%Load STM data from UI selected file of variable formats (.3ds, .sxm,) 
%   Select data file using the UI. Basen on the file extension the 
%   appropriate specific loading function for that dataype is chosen. 
%   The user is asked to specify the <name> of the subfield of data.<name> 
%   the actual data is assigned to. E.g: data.topoBefore, or data.grid. 

%   Requires the toplevel data struct variable to be parsed. In this case 
%   the function adds the field data.<name> to it. 

% M. Altthaler 2024; V. King 2025

arguments
    data        
end

logC = 0; %default is to not use commentC
commentC = ""; %default is to not use commentC

%select data via UI
[filePath, fileName, fileExt] = selectData();
fullFileName = strcat(fileName, fileExt);

%selecting the fieldName for data.<fieldName> to be assigned the loaded data
fieldName = fieldNamePrompt();
if isfield(data,fieldName)
    %fieldname already in use
    fieldName = fieldNamePrompt(fieldName);
end


%actual loading
switch fileExt
    case '.Z_flat'
        %load matrix topo
        topo = load_topo_Matrix(filePath, fullFileName);
        data.(fieldName) = topo;
    case '.I(V)_flat'
        %load matrix grid
        [grid, grid_topo, commentC] = load_grid_Matrix(filePath, fullFileName);
        data.(fieldName) = grid;
        data.(strcat(fieldName,'_topo')) = grid_topo;
        logC = 1;
    case '.3ds'
        %load 3ds file -> Nanonis grid
        grid = load_grid_Nanonis(filePath,fullFileName);
        data.(fieldName) = grid;
    case '.sxm'
        %load sxm file -> Nanonis topo
        topo = load_topo_Nanonis(filePath, fullFileName);
        data.(fieldName)= topo;
    case '.dat'
        %load dat file -> Nanonis point spectrum
        spectrum = load_spectrum_Nanonis(filePath, fullFileName);
        data.(fieldName)= spectrum;
    otherwise
        disp("No file of appropriate data type selected");
        commentC = "No file of appropriate data type selected";
end

%save the fieldName as the name of the data set
data.(fieldName).dataSetName = fieldName;

%log function call
commentA = sprintf("[data.%s, ...] = loadData(data); Selected data: <path>/<file>", fieldName);

%log selected file
commentB = sprintf("%s/%s", filePath, fullFileName);


end