function [data, commentA, commentB, commentC, commentD] = loadData(data)
%Load STM data from UI selected file of variable formats (.3ds, .sxm,) 
%   Select data file using the UI. Basen on the file extension the 
%   appropriate specific loading function for that dataype is chosen. 
%   The user is asked to specify the <name> of the subfield of data.<name> 
%   the actual data is assigned to. E.g: data.topoBefore, or data.grid. 

%   Requires the toplevel data struct variable to be parsed. In this case 
%   the function adds the field data.<name> to it. 

arguments
    data        
end

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
        disp("<name>.Z_flat files are not supported yet. Work in progress! No data was loaded");
        commentC = "<name>.Z_flat files are not supported yet. Work in progress! No data was loaded";
    case '.I(V)_flat'
        %load matrix grid
        disp("<name>.I(V)_flat files are not supported yet. Work in progress! No data was loaded");
        commentC = "<name>.I(V)_flat files are not supported yet. Work in progress! No data was loaded";
    case '.3ds'
        %load 3ds file -> Nanonis grid
        [grid, commentC] = load_grid_Nanonis(filePath,fullFileName);
        data.(fieldName) = grid;
    case '.sxm'
        %load smx file -> Nanonis topo
        [topo, commentC] = load_topo_Nanonis(filePath, fullFileName);
        data.(fieldName)= topo;
    case '.dat'
        %load dat file -> Nanonis point spectrum
        disp("<name>.dat files are not supported yet. Work in progress! No data was loaded");
        commentC = "<name>.dat files are not supported yet. Work in progress! No data was loaded";
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