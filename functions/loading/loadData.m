function [data, commentA, commentB, commentC, commentD] = loadData(data, direction)
%Load STM data from UI selected file of variable formats (.3ds, .sxm,) 
%   Select data file using the UI. Basen on the file extension the 
%   appropriate specific loading function for that dataype is chosen. 
%   The user is asked to specify the <name> of the subfield of data.<name> 
%   the actual data is assigned to. E.g: data.topoBefore, or data.grid. 

%   Requires the toplevel data struct variable to be parsed. In this case 
%   the function adds the field data.<name> to it. 

%   Optional arguments (to be expanded)
%   direction   is an optional input to specify the direcion 'forward' or
%               'backward' a topo image (.sxm) is loaded

arguments
    data        
    direction   {mustBeText}="forward"
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
    case '.I(V)_flat'
        %load matrix grid
    case '.3ds'
        %load 3ds file -> Nanonis grid
        [grid, commentC] = load_grid_Nanonis(filePath,fullFileName);
        data.(fieldName) = grid;
    case '.sxm'
        %load smx file -> Nanonis topo
        [topo, commentC] = load_topo_Nanonis(filePath, fullFileName, direction);
        data.(fieldName)= topo;
    case '.dat'
        %load dat file -> Nanonis point spectrum
    % case '.mat'
    %     %load .mat file -> Matlab workspace
    %     load(strcat(filePath,fileName,fileExt));
    %     %Note this option allows you to load a previously saved workspace.  
    %     %Only use it if you saved a workspace created by loading data via
    %     %this block before!
    otherwise
        disp("No file of appropriate data type selected");
        commentC = "No file of appropriate data type selected";
end

%log function call
commentA = sprintf("[data.%s, ...] = loadData(data,direction = %s); Selected data: <path>/<file>", fieldName, direction);

%log selected file
commentB = sprintf("%s/%s", filePath, fullFileName);


end