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

%%%%%%%%%%%%%%%%%%%%%%%%%% help functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fieldName] = fieldNamePrompt(fieldNameIn)
%Prompts user to give a field name:
%   Asks for user input to set the field name. The input can either be a
%   prest name or a free input. Free inputs may only contain up to 64
%   letters, numbers and underscores, i.e. characters: a-z, A-Z, 0-9, _. 
%   Any other characters will be removed from the string without warning!

% M. Altthaler, April 2024 & October 2024

arguments
    fieldNameIn {mustBeText}= ""
end
 
    if fieldNameIn == ""
        %no field name parsed - initial setting
        disp('The data file you selected will be saved as data.<name>');
        disp('To default to a preset type #');
        disp('1: <name> = grid');
        disp('2: <name> = topo');
        disp('3: <name> = topoBefore');
        disp('4: <name> = topoAfter');
        disp('5: <name> = IVcurve');
        disp('A freely chosen <name> may only contain capital (A-Z) and non-capital (a-z) letters numbers (0-9) and underscores (_)!')
        str = input('Please type the <name> you desire:' ,"s");
        switch str
            case '1'
                fieldName = 'grid';
            case '2'
                fieldName = 'topo';
            case '3'
                fieldName = 'topoBefore';
            case '4'
                fieldName = 'topoAfter';
            case '5'
                fieldName = 'IVcurve';
            otherwise
                %free name assignment
                %filter space and other fobidden chars!
                str = regexprep(str,'[^a-zA-Z0-9_\s]','');
                str = erase(str, " ");
                if strlength(str) <65
                    fieldName = str;
                else
                    disp('Name exceeds limit of 64 characters');
                end
        end
    else 
        %field name parsed - field already exists
        disp('------------------------------------------------------------------------------')
        strOut = sprintf('The field data.<name> = data.%s is already in use!', fieldNameIn);
        disp(strOut);
        disp('You can overwrite the exising field or chose a new name.');
        disp('To default to a preset type # or type the new name (see above for details)');
        strOut = sprintf('0: overwrite with the chosen name: %s', fieldNameIn);
        disp(strOut);
        str = input('Please type the <name> you desire:' ,"s");
        switch str
            case '0'
                fieldName = fieldNameIn;
            case '1'
                fieldName = 'grid';
            case '2'
                fieldName = 'topo';
            case '3'
                fieldName = 'topoBefore';
            case '4'
                fieldName = 'topoAfter';
            case '5'
                fieldName = 'IVcurve';
            otherwise
                %free name assignment
                %filter space and other fobidden chars!
                str = regexprep(str,'[^a-zA-Z\s]','');
                str = erase(str, " ");
                if strlength(str) <65
                    fieldName = str;
                else
                    disp('Name exceeds limit of 64 characters');
                end
        end    
    end    

end