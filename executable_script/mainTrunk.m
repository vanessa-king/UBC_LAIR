%% Script for data processing with logging

%% Block logging

% This section outlines the guidelines for naming and logging each block in the code.

% 1. Block Identifier Format
%    Each block must have a unique 5-character identifier of the form: ABXXZ
%       - A:   Category of the block:
%              L = Loading (e.g. reading/importing data)
%              P = Processing (e.g. data transformation, filtering)
%              V = Visualizing (e.g. plotting/generating figures)
%              S = Selecting (e.g. making a mask or a veil)
%              S = Saving (e.g. saving workspace)
%       - B:   Subcategory of the block, based on the task being performed:
%              Examples (based on block list as of Oct 2024): 
%               A = Averaging
%               D = Data
%               F = Flatten
%               G = Grid
%               I = Initialize 
%               M = Mask
%               S = Spectrum
%               T = Threshold
%               W = Workspace
%       - XX:  Running number for consecutive blocks (01, 02, ..., 99)
%       - Z:   Alternating letter for variations of a block (a, b, c, ...)

% 2. Block Header Format
%    Each block starts with a block header in this format:
%       %% ABXXZ Axxx-Bxxx-XX-Z; <short description of the block’s function>
%       - Axxx: Spelled-out form of the main category (e.g., V -> Visualizing)
%       - Bxxx: Spelled-out form of the subcategory (e.g., S -> Spectrum)
%       - XX:   Running number
%       - Z:    Variation letter for related blocks
%    See block list for full examples.

% 3. Using the logUsedBlocks() Function
%       - The logUsedBlocks() function logs: the time and date of execution; the block identifier (ABXXZ);
%         and the LOGcomment a string summarizing all functions used and their parameters.
%    
%    Format of LOGcomment:
%        - LOGcomment = "functionA(param1 = value1, param2 = value2); functionB(param = value);"
%    
%    When multiple functions are logged within the same block, only the 
%    first call logs the block identifier (ABXXZ). Subsequent logs use the symbol "  ^  ".

% 4. Saving Figures or Data
%    If a block generates output (e.g. figures), use uniqueNamePrompt() to assign a default name.
%       - This function allows the user to change the default name.
%       - If a file of the same name already exists, a 3-digit running number is appended.
%    
%    Save and log the output using savefig() and saveUsedBlocksLog():
%       Example:
%          figName = uniqueNamePrompt("SmoothedData", "", LOGpath);
%          savefig(figName);
%          saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, figName);

% 5. Handling Multiple Functions in a Block
%    If multiple functions are called within a block, log each call individually.
%    If a function generates output, log and save it using saveUsedBlocksLog().
%    Example:
%       filteredData = filterData(data, filterParams);
%       LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PF01A", "filterData(params);", 0);
%       saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, "FilteredData");


% This log file and block naming system ensures reproducibility and proper 
% tracking of each block’s function calls, parameters, and saved outputs.
%% Block List
%Loading
    % LI01B Load-Initialize-01-B; Initialize log file, UI select path and name
    % LD01A Load-Data-01-A; Load data (grid, topo, ...) via UI file selection
    % LS02A Load-Spectra-01-A; load grid and topo from Nanonis
    % SW01A Save-Workspace-01A; Save the current workspace
    % LW01A Load-Workspace-01A; Loads a saved workspace from a .mat file
%Selecting
    % SL01A Selecting-Logic-01-A; logic AND for two masks
    % SL02A Selecting-Logic-02-A; logic OR for two masks
    % SI01A Selecting-Invert-01-A; invert mask (or veil)
    % SM01A Selecting-Mask-01-A; select a directional mask (with/without binning)
    % SM02A Selecting-Mask-02-A; circular mask
    % SM03A Selecting-Mask-03-A; rectangular mask
    % SM04A Selecting-Mask-04-A; threshold mask
    % SM05A Selecting-Mask-05-A; polygon mask
%Processing    
    % PA01A Processing-Averaging-01-A; applies moving-average smoothing to I-V
    % PA02A Processing-Averaging-Mask-02-A; average I-V or dI/dV according to a mask
    % PD01A Processing-Derivative-01-A; create a regular dIdV for I-V
    % PD01B Processing-Derivative-01-B; create a nomarlized dIdV (i.e. dIdV/I-V)
    % PC02A Processing-Correcting-02-A; correct the grid for drift 
    % PF01A Processing-Flatten-01-A; Subtracts the plane in topography images
    % PI03A Processing-Image-01-A; apply function to two images (add, subtract, ...)
    
%Visualizing
    % VT03A Visualize-Topo-03-A;  2D Image Plotting (topography or grid slice)
    % VS01A Visualize-Spectrum-01-A; plot average I-V or average dI/dV
    % VS02A Visualize-Spectrum-02-A; allows you to click on a grid/topo and plot the spectra
    % VS04A Visualize-Spectra-04-A: Unified Plotting of I/V and dI/dV Profiles
    % VG01A Visualize-Grid-01-A: gridslice viewer for all grids (including the non-square one)
%Retired
    % R-VT01A Visualize-Topo-01-A; visualizes a slice of dI/dV data at a user-defined bias
    % R-VT02A Visualize-Topo-02-A; 2D Image Plotting (topography)
    % R-LI01A Load-Initialize-01-A; Initializing the log file and choosing the data
    % R-LG01A Load-Grid-01-A; load grid 
    % R-LG01B Load-Grid-01-B; load grid and topo from Nanonis
    % R-LS02A Load-Spectra-01-A; load spectra from Nanonis
    % R-PT01A Processing-Threshold-01-A; Gets threshold from the height distribution of topo;
    % R-PT02A Processing-Transforming-01-A: Transforms Flat-Style Matrix Data to Nanonis Array-Style
    % R-VS03A Visualize-Spectrum-03-A; circular masking;
    % R-VS03B Visualize-Spectrum-03-B; rectangular masking;


%% LI01B Load-Initialize-01-B; Initialize log file, UI select path and name
%   Edited by M. Altthaler, April 2024

% This section of code specifies the <paths> and <name> of the LOG file. 
% Subsequently the <path>\<name>_LOGfile.txt is initialized with this information. 
 
% select LOGpath and LOGfile
% UI to choose <paths> and an input prompt for the log file <name>
% Note: _LOGfile.txt will be appended to the chosen name!

%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[LOGpath,LOGfile] = setLogFile();

% Initialize LogFile 
%initialize LOG file & log name and directory
LOGcomment = "Initializing log file: <LOGpath>/<LOGfile>_LOGfile.txt";
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LI01B", LOGcomment, 1);
LOGcomment = strcat(LOGpath,"/",LOGfile,"_LOGfile.txt");
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

% initialize empty data struct 
data = {};

%% LD01A Load-Data-01-A; Load data (grid, topo, ...) via UI file selection
% Edited by M. Altthaler, April 2024

% This block allows users to pick a file of data (i.e. the data set) via UI. 
% The load function picks the appropriate specific load function for the 
% data type based on file the extension (compatible formats to be expanded). 
% The user sets the <name> of the field the data set is assigned to. All 
% data is saved in the format: data.dataset.variable

% Returns: data.<name>, where <name>.<varName> is the actual data, e.g.:
% data.<name>.I     --> I(V) data from a .3ds file 
% data.<name>.z     --> topo (z) data from a .sxm file

%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[data, commentA, commentB, commentC, logC] = loadData(data);

% log use of block, and the specific data and field name assigned
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LD01A", commentA, 0);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", commentB, 0);
if logC ==1
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", commentC, 0);
end

%% SW01A Save-Workspace-01A; Save the current workspace
% Edited: M. Altthaler July,2024;
% This block saves the current work space (all assigned variables) to a file 
% and saves a copy of the LOGfile with it. 
% By default these are saved in the LOGpath and the name is set to the 
% LOGfile name with the date (format: '_DD-MMM-YYY_hh-mm-ss') appended. 

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%select folder and file name
targetFolder = uigetdir(LOGpath,"Specify the folder to save the workspace in:");
dateStr = string(datetime);
dateStr = regexprep(dateStr, ' ', '_'); %repalce space with _ to avoid issue with filename in save
dateStr = regexprep(dateStr, ':', '-'); %repalce : with - to avoid issue with filename in save
defName = strcat(LOGfile,'_',dateStr);
fileName = uniqueNamePrompt(defName,'',targetFolder);

clear dateStr defName
%save workspace
save(strcat(targetFolder,'/',fileName))

%LOG block execution
LOGcomment = sprintf("Saved current workspace as %s/%s.mat",targetFolder,fileName);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "SW01A", LOGcomment ,0);

%save copy of LOG with with the .mat file
saveUsedBlocksLog(LOGpath, LOGfile, targetFolder, fileName); 

clear targetFolder fileName
%% LW01A Load-Workspace-01A; Loads a saved workspace from a .mat file 
% Edited: M. Altthaler July,2024;
% This block loads a work space (all assigned variables) from a 
% <dir>/<fileName>.mat file. The corresponding copy of the original LOGfile 
% <dir>/<fileName>_LOGfile.txt (automatically created when saving a 
% workspace with block SW01A) is required in the same folder to load a 
% workspace! 
% If a workspace is 'imported' from another device and the original LOGpath
% directory does not exist, the user is asked to reassign it via GUI. 

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cont = input("Loading a workspace clears your current workspace! Do you want to continue? Y/N [Y]:","s");
if isempty(cont)
    cont = 'Y';
end

if cont=='Y'|cont=='y'
    %clear workspace and go on with the execution
    disp('Current workspace cleared. Use GUI to select workspace to load.')
    clear 
    %
    %UI select saved workspace (.mat file)
    [tempFile,filePath] = uigetfile('*.mat','Select saved workspace:');
    [~, fileName, ext] = fileparts(tempFile);
    if ext == ".mat"
        %<dir>/<name>.mat file selected:
        fullFileName = strcat(filePath,'/',fileName,ext);
        %check if corresponding <dir>/<name>_LOGfile.txt exists
        savedLOGfileName = strcat(filePath,'/',fileName,'_LOGfile.txt');
        if isfile(savedLOGfileName)
            % corresponding <dir>/<name>_LOGfile.txt exists, load <dir>/<name>.mat file
            load(fullFileName)
            %check if LOGpath and LOGfile variable exist in the loaded workspace
            if exist('LOGfile','var') && exist('LOGpath','var') && exist('data','var')
                %valid workspace
                clear targetFolder fileName %they always get saved in SW01A as they are needed in the save command (but not outside the block)
                %check if the restored LOGpath exists on this device - if
                %not a new directory has to be assigned via GUI
                if ~isfolder(LOGpath)
                    %LOGpath does not exist on local machine
                    clear LOGpath 
                    disp('Select folder for the updated LOG path on this PC via GUI')
                    LOGpath = uigetdir([],'Select folder for the updated LOG path on this PC:');
                end
                %restore LOG in <LOGpath>/<LOGfile>_LOGfile.txt from <dir>/<name>_LOGfile.txt
                restoredLOG = strcat(LOGpath,'/',LOGfile,'_LOGfile.txt');
                copyfile(savedLOGfileName, restoredLOG)
                %LOG execution in the resored LOG file
                LOGcomment = "Loaded workspace and restored corresponding LOGfile";
                disp(LOGcomment)
                LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LW01A", LOGcomment, 0);
                LOGcomment = strcat("Loaded workspace: <dir>/<name>.mat = ",fullFileName);
                disp(LOGcomment)
                LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);
                LOGcomment = strcat("Source LOGfile: <dir>/<name>_LOGfile.txt = ",savedLOGfileName);
                disp(LOGcomment)
                LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);
                LOGcomment = strcat("Restored LOGfile: <LOGpath>/<LOGfile>_LOGfile.txt = ",restoredLOG);
                disp(LOGcomment)
                LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);
            else
                %invalid workspace
                clear
                disp("Invalid workspace loaded!")
                disp("Workspace does not contain required variables: LOGfile, LOGpath, data")
            end
        else
            % <dir>/<name>_LOGfile.txt does not exist.
            disp('Workspace cannot be loaded!')
            disp('No matching <name>_LOGfile.txt found for the selected workspace <name>.mat in <dir>.');
            disp(sprintf("<name> = %s",fileName))
            disp(sprintf("<dir> = %s",filePath)) 
        end
    else
        disp('Workspace cannot be loaded!')
        disp('Wrong file type selected. A <name>.mat file has to be selected.')
    end

else  % n, N, and all other inputs
    disp('Execution aborted.')
    LOGcomment = "Execution aborted.";
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LW01A", LOGcomment, 0);
end
clear cont tempFile filePath fileName ext fullFileName savedLOGfileName restoredLOG

%% SL01A Selecting-Logic-01-A; logic AND for two masks
% Edited by M. Altthaler 01/2025

% This block applies AND logic to two masks of equal size and returns 
% the result as a mask. (AND-mask is true where both masks are true) 

%presets:
dataset = 'grid';           % specify the dataset to be used: e.g. grid
variableIn1 = 'maskA';      % specify the 1st mask 
variableIn2 = 'maskB';      % specify the 2nd mask
variableOut = 'ANDmask';    % specify the name of the returned mask

%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LOG data in/out:
LOGcomment = sprintf("DataIn: data.%s.%s, data.%s.%s; dataOut: data.%s.%s", dataset, variableIn1, dataset, variableIn2, dataset, variableOut);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "SL01A", LOGcomment, 0);

%function execution 
[data.(dataset).(variableOut), LOGcomment] = logicANDmask(data.(dataset).(variableIn1),data.(dataset).(variableIn2));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

% Clear preset variables
clearvars dataset variableIn1 variableIn2 variableOut

%% SL02A Selecting-Logic-02-A; logic OR for two masks
% Edited by M. Altthaler 01/2025

% This block applies OR logic to two masks of equal size and returns 
% the result as a mask. (OR-mask is true where at leat one of the masks is true) 

%presets:
dataset = 'grid';           % specify the dataset to be used: e.g. grid
variableIn1 = 'maskA';      % specify the 1st mask 
variableIn2 = 'maskB';      % specify the 2nd mask
variableOut = 'ORmask';    % specify the name of the returned mask

%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LOG data in/out:
LOGcomment = sprintf("DataIn: data.%s.%s, data.%s.%s; dataOut: data.%s.%s", dataset, variableIn1, dataset, variableIn2, dataset, variableOut);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "SL02A", LOGcomment, 0);

%function execution 
[data.(dataset).(variableOut), LOGcomment] = logicORmask(data.(dataset).(variableIn1),data.(dataset).(variableIn2));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

% Clear preset variables
clearvars dataset variableIn1 variableIn2 variableOut

%% SI01A Selecting-Invert-01-A; invert mask (or veil) 
% Edited by M. Altthaler 01/2025

% This block inverts a mask (or veil), i.e. 0->1, 1->0 (0.9->0.1, 0.8->0.2, ...)
% Normalizes the mask (or veil) to [0, 1].
% Note: works like 'mask = ~mask' with logging for logical masks. 

%presets:
dataset = 'grid';               % specify the dataset to be used: e.g. grid
variableIn1 = 'maskA';           % specify the mask 
variableOut = 'invertedMask';   % specify the name of the returned mask

%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LOG data in/out:
LOGcomment = sprintf("DataIn: data.%s.%s dataOut: data.%s.%s", dataset, variableIn1, dataset, variableOut);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "SI01A", LOGcomment, 0);

%function execution 
[data.(dataset).(variableOut), LOGcomment] = invertMask(data.(dataset).(variableIn1));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

% Clear preset variables
clearvars dataset variableIn1 variableOut

%% SM01A Selecting-Mask-01-A; creates directional masks for data analysis
% Edited by Dong Chen in Dec 2024
%
% This section creates masks along a user-defined direction with specified width
% and optionally combines them using binning parameters.
%
% The masks can be used for:
% - Averaging data along specific directions
% - Analyzing patterns in specific orientations
% - Creating binned data for statistical analysis

%presets:
dataset = 'grid';           % specify the dataset to be used: e.g. grid
variableIn = 'I';          % specify the variable to be processed   
variableOut = 'directional_masks';     % specify the variable name to store the masks
connected = false;         % flag for side connectivity in mask generation

% Optional variable inputs
% set values to [] if not used
startPoint = [];           % [x,y] coordinates of start point, [] for interactive selection
endPoint = [];            % [x,y] coordinates of end point, [] for interactive selection
bin_size = 2;             % number of masks to combine in each bin
bin_sep = 3;              % separation between consecutive bins

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LOG data in/out:
LOGcomment = sprintf("DataIn: %s.%s; dataOut: %s.%s", ...
    dataset, variableIn, dataset, variableOut);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "SM01A", LOGcomment, 0);

% Get input data
inputData = data.(dataset).(variableIn);

% Create directional masks
[data.(dataset).(variableOut), data.(dataset).([variableOut '_combined']), LOGcomment] = ...
    maskDirectional(inputData, ...
    'connected', connected, ...
    'startPoint', startPoint, ...
    'endPoint', endPoint, ...
    'bin_size', bin_size, ...
    'bin_sep', bin_sep);

LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

% Clean up variables
clearvars dataset variableIn variableOut connected startPoint endPoint bin_size bin_sep inputData slice_idx 
%% SM02A Selecting-Mask-02-A; circular mask

% Edited by Jiabin May 2024; Jisun Oct 2023, again in Feb 2024, again in Dec 2024.
% This section of code creates a circular mask of radius R around a clicked point. 
% It then plots the average dI/dV on that point. The user may toggle R and energy slice.

% presets:
dataset ='grid';            % specify the dataset to be used: e.g. grid
variableIn1 = 'I';       % specify the data (2D or 3D) to use to create the mask
radius = 3;                 % radius R: the size of the circular mask

% optional variable inputs
% set values to [] if not used
% Relevant inputs for slicing 3D -> 2D data:
n = 113;                         % slice number (n-th index of 3rd dim of data) [variableIn2 optional]
variableIn2 = 'V';      % Voltage axis for the 3D data set: e.g. 'V_reduced' for dIdV or 'V' for I(V)
imageV = [];                 % target voltage -> closest value in variableIn2 is chosen [requires variableIn2]

% return variables:
variableOut1 = 'circular_mask';              % return the function of execution
variableOut2 = 'num_in_mask';

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% LOG data in/out
LOGcomment = sprintf("dataset = %s; variableIn1 = %s; radius = %s; n = %s; variableIn2 = %s; imageV = %s; variableOut1 = %s; variableOut2 = %s; ", dataset, variableIn1, num2str(radius), num2str(n), variableIn2, num2str(imageV), variableOut1, variableOut2);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "SM02A", LOGcomment ,0);

% excute the function
[data.(dataset).(variableOut1), data.(dataset).(variableOut2), LOGcomment] = maskPoint(data.(dataset).(variableIn1), radius, n, optionalStructCall(data, dataset,variableIn2), imageV);

% log the function of excuation 
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

% Ask for dir of saving `figure` and the name 
targetFolder = uigetdir([],'Choose folder to save the figure to:');
plot_name = uniqueNamePrompt("circular mask","",targetFolder);

% LOG dir/plotname.fig
LOGcomment = sprintf("Figure saved as (<dir>/<plotname>.fig): %s/%s.fig", targetFolder, plot_name);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);
    
% save the figures
savefig(strcat(targetFolder,"/",plot_name,".fig"));

% function: SaveUsedBlocks
saveUsedBlocksLog(LOGpath, LOGfile, targetFolder, strcat(plot_name));

% clear excess variables
clearvars dataset variableIn1 variableIn2 variableOut1 variableOut2
clearvars imageV radius targetFolder plot_name

%% SM03A Selecting-Mask-03-A; rectangular mask
% Edited by Jisun Dec 2024
% This section of code creates a rectangular mask. The user clicks two points that define 
% a single rectangle (presumably, opposite corners). 
% It then plots the average dI/dV of the selected area.

% presets:
dataset ='grid';              %specify the dataset to be used: e.g. grid
variableIn1 = 'I';         % specify the data (2D or 3D) to use to create the mask

% optional variable inputs
% set values to [] if not used
% Relevant inputs for slicing 3D -> 2D data:
n = 113;                         % slice number (n-th index of 3rd dim of data) [variableIn2 optional]
variableIn2 = 'V';      % Voltage axis for the 3D data set: e.g. 'V_reduced' for dIdV or 'V' for I(V)
imageV = [];                 % target voltage -> closest value in variableIn2 is chosen [requires variableIn2]

% return variables:
variableOut1 = 'rectangular_mask';              % return the function of execution
variableOut2 = 'Num_in_mask';

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% LOG data in/out
LOGcomment = sprintf("dataset = %s; variableIn1 = %s; n =%s; variableIn2 = %s; imageV = %s; variableOut1 = %s; variableOut2 = %s; ", dataset, variableIn1, num2str(n), variableIn2, num2str(imageV), variableOut1, variableOut2);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "SM03A", LOGcomment ,0);

% excute the function
[data.(dataset).(variableOut1), data.(dataset).(variableOut2), LOGcomment] = maskRectangle(data.(dataset).(variableIn1), n, optionalStructCall(data, dataset,variableIn2), imageV);

% log the function of excuation 
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

% Ask for dir of saving `figure` and the name 
targetFolder = uigetdir([],'Choose folder to save the figure to:');
plot_name = uniqueNamePrompt("rectangular mask","",targetFolder);

% LOG dir/plotname.fig
LOGcomment = sprintf("Figure saved as (<dir>/<plotname>.fig): %s/%s.fig", targetFolder, plot_name);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);
    
% save the figures
savefig(strcat(targetFolder,"/",plot_name,".fig"));

% function: SaveUsedBlocks
saveUsedBlocksLog(LOGpath, LOGfile, targetFolder, strcat(plot_name));

% clear excess variables
clearvars dataset variableIn1 variableIn2 variableOut1 variableOut2
clearvars imageV targetFolder plot_name

%% SM04A Selecting-Mask-04-A; threshold mask
% Edited by Rysa Greenwood Nov 2023, Rysa July 2024, Jisun March 2025
% This block makes a mask based on user defined z or dI/dV threshold

% presets:
dataset ='grid';                %specify the dataset to be used: e.g. grid or topo
variableIn1 = 'I';           % specify the data (2D or 3D) to use to create the mask
plot_histograms = true;         % true if you would like to see the intermediate histogram to help choose your desired threshold value; false if not

% optional variable inputs
% set values to [] if not used
% Relevant inputs for slicing 3D -> 2D data:
n = 111;                         % slice number (n-th index of 3rd dim of data) [variableIn2 optional]
variableIn2 = 'V';      % Voltage axis for the 3D data set: e.g. 'V_reduced' for dIdV or 'V' for I(V)
imageV = [];                  % target voltage -> closest value in variableIn2 is chosen [requires variableIn2]
                                
% return variables: 
variableOut = 'threshold_mask';  % mask based on the threshold value   

%%%%%%%%%%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% log input variable
%add log
LOGcomment = sprintf("DataIn: dataset = %s, variableIn1 = %s, variableIn2 = %s, n = %s; imageV = %s; dataOut: variableOut = %s",dataset ,variableIn1, variableIn2, num2str(n), imageV, variableOut);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "SM04A", LOGcomment ,0);

%function execution
[data.(dataset).(variableOut), LOGcomment] = getThreshold(data.(dataset).(variableIn1), plot_histograms, n, optionalStructCall(data, dataset,variableIn2), imageV);

%ask for plotname:
plot_name = uniqueNamePrompt("Threshold","",LOGpath);
LOGcomment = strcat(LOGcomment,sprintf(", plotname=%s",plot_name));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

%save the created figures here:
savefig(strcat(LOGpath,"/",plot_name,".fig"))
%create copy of the log corresponding to the saved figures
saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, plot_name);

%clear variables
clearvars dataset variableIn1 variableIn2 variableOut n imageV
clear plot_name

%% SM05A Selecting-Mask-03-A; polygon mask
% Edited by M. Altthaler 2025/02
% This section of code creates a polygon mask. The user defines a polygon 
% by clicking to select an areas for the mask. 

% presets:
dataset ='grid';                %specify the dataset to be used: e.g. grid
variableIn1 = 'I';              % specify the data (2D or 3D) to use to create the mask

% optional variable inputs
% set values to [] if not used
% Relevant inputs for slicing 3D -> 2D data:
n = 111;                         % slice number (n-th index of 3rd dim of data) [variableIn2 optional]
variableIn2 = 'V';              % Voltage axis for the 3D data set: e.g. 'V_reduced' for dIdV or 'V' for I(V)
imageV = [];                  % target voltage -> closest value in variableIn2 is chosen [requires variableIn2]
                                
positionsIn = [];               % list of points for the polygon in the format: [x1 y1; x2 y2; ...; xn yn]; 
                                % Note: you can assign positionsIn = data.(dataset).polygonPoints; but you cannot assing 'polygonPoints' 

% return variables: 
variableOut1 = 'polygon_mask';  % polygon mask as defined by user / positionsIn  
variableOut2 = 'polygonPoints'; % point list of (x,y)-coordinates definign the polygon  

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% LOG data in/out
LOGcomment = sprintf("dataset = %s; variableIn1 = %s; variableIn2 = %s; variableOut1 = %s; variableOut2 = %s; n = %s; imageV = %s; positionsIn = %s; ", dataset, variableIn1, variableIn2, variableOut1, variableOut2, num2str(n), num2str(imageV), mat2str(positionsIn));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "SM05A", LOGcomment ,0);

%execute function
[data.(dataset).(variableOut1), data.(dataset).(variableOut2), LOGcomment] = maskPolygon(data.(dataset).(variableIn1),n,optionalStructCall(data, dataset,variableIn2),imageV,positionsIn);

% log the function of excuation 
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

% clear excess variables
clearvars dataset variableIn1 variableIn2 variableOut1 variableOut2 n imageV positionsIn
clearvars imageV targetFolder plot_name
%% PA01A Processing-Averaging-01-A; applies moving-average smoothing to I-V
%Edited by M. Altthaler April 2024; James October 2023; Jisun October 2023

% This section of code applies moving-average smoothing to the I-V data of the grid. 

%presets:
dataset = 'grid';   % specify the dataset to be used: e.g. grid
variableIn = 'I';  % specify the variable to be processed, e.g. I. Note that by default ‘I’ is the forward scan
variableOut = 'I_smoothed'; % specify the variable to return the data to, e.g. I_smoothed
span = 3;       %size of the moving window. E.g. 3: for nearest neighbor averaging; 5 for next nearast neighbor averaging.

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LOG data in/out:
LOGcomment = sprintf("DataIn: %s.%s; dataOut: %s.%s",dataset ,variableIn , dataset, variableOut);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PA01A", LOGcomment ,0);


[data.(dataset).(variableOut), LOGcomment] = smoothData(data.(dataset).(variableIn),span,'IV');
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

clearvars dataset variableIn variableOut span

%% PA02A Processing-Averaging-Mask-02-A; average I-V or dI/dV according to a mask
% Edited by Jisun Kim Oct 2023, again in Feb 2024, Dong Chen June 2024
% This section of code averages the I-V data according to a given mask.

% Presets
% Define dataset and input/output variables here
dataset = 'grid';               % specify the dataset to be used: e.g., grid
variableIn1 = 'dIdV';     % the variable that you want to average. e.g. I_forward, I_backward
                                % If you want to average dIdV, you need to run PD01A or PD01B first. 
                                % Also you can input dIdV_forward or dIdV_backward to get average 
                                % of foward or backward only average dIdV.

% optional variable input: set value to [] if not used
variableIn2 = [];  % If you want to average I-V or dIdV only in the masked area, specify the mask here. 
                               % You need to run one of Selecting blocks:
                               % e.g. run SM05A and set the variableIn2 as 'polygon_mask'.

% return variables:
variableOut1 = 'avg_dIdV';      % specify the first output variable. e.g. avg_dIdV or avg_IV_fwd or avg_IV_bwd
                                % or avg_dIdV_fwd or avg_dIdV_bwd
variableOut2 = 'dIdV_STD';      %standard deviation
%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Log input and output variables
LOGcomment = sprintf("DataIn: dataset = %s, variableIn1 = %s, variableIn2 = %s; DataOut: variableOut1 = %s, variableOut2 = %s", ...
    dataset, variableIn1, variableIn2, variableOut1, variableOut2);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PA02A", LOGcomment, 0);

% Main code execution section

% Function call
[~, data.(dataset).(variableOut1), data.(dataset).(variableOut2), LOGcomment] = avgXYmask(requiredStructCall(data,dataset,variableIn1), optionalStructCall(data,dataset,variableIn2));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

% Clear preset variables
clearvars dataset variableIn1 variableOut1

%% PD01A Processing-Derivative-01-A; create a regular dIdV. 
% Edited by: Jisun November 2023, again in May 2024

% This section of code creates a regular dIdV data from the grid. It will create dIdV for I-V

%presets:
dataset = 'grid';           % specify the dataset to be used: e.g. grid
variableIn1 = 'I_smoothed'; % specify the variable to be processed, e.g. I, I_smoothed, or I_backward
                            % this is a 3d array form (x, y, V)
variableIn2 = 'V';          % specify the variable to be processed, e.g. V or Z
                            % this is a 1d array form (V, 1)
variableOut1 = 'dIdV';      % specify the variable to return the data to
                            % this is a 3d array form (x, y, V-1)
variableOut2 = 'V_reduced'; % specify the variable to return the data to
                            % this is a 1d array form (V-1, 1)
%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LOG data in/out:
LOGcomment = sprintf("DataIn: dataset = %s, variableIn1 = %s, variableIn2 = %s; dataOut: dataset = %s, variableOut1 = %s, variableOut2 = %s",dataset, variableIn1, variableIn2, dataset, variableOut1, variableOut2);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PD01A", LOGcomment ,0);

[data.(dataset).(variableOut1), data.(dataset).(variableOut2), LOGcomment] = Derivative(data.(dataset).(variableIn1),data.(dataset).(variableIn2));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

clearvars dataset  
clearvars variableIn1 variableIn2 
clearvars variableOut1 variableOut2 
%% PD01B Processing-Derivative-01-B; create a normalized dIdV (i.e. dIdV/I-V).
% When you run this section, your didv becomes/means normalized didv 
% and your grid.I becomes/means offset corrected I (see NormDerivative for details).
% Edited by: Jisun November 2023, again in June 2024
% This section of code creates a normalized dIdV data from the grid. 

% Presets
% Define dataset and input/output variables here
dataset = 'grid';           % Specify the dataset to be used, e.g., grid.
variableIn1 = 'I_smoothed'; % Specify the variable to be processed, e.g. I, I_Forward, or I_Backward.
                            % This is a 3d array form (x, y, V).
variableIn2 = 'V';          % Specify the variable to be processed, e.g. V.
                            % This is a 1d array form (V, 1).
C = 3E-10;                  % This is a pneumetic value to deal with the diverging value at V=0 while normalizing.

% define the folder where the created figure to be saved
savefigpath = '';   % If you choose '', it will pop up a window for a user to select the folder to save the figure.
                    % Or you can just directly put a path here: e.g. savefigpat = LOGpath. This must be string.

                            
variableOut1 = 'norm_dIdV'; % This is a 3d array form (x, y, V-1).                            
variableOut2 = 'V_reduced'; % This is a 1d array form (V-1, 1).                            
variableOut3 = 'I_corrected'; % This is a 1d array form (x, y, V).                            
variableOut4 = 'I_offset';  % This is a 1d array form (x, y).                            
variableOut5 = 'I_offset_std'; % This is a neumetic value.

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Log input and output variables
LOGcomment = sprintf("DataIn: dataset = %s, variableIn1 = %s; variableIn2 = %s; C = %s, DataOut: dataset = %s, variableOut1 = %s, variableOut2 = %s, variableOut3 = %s, variableOut4 = %s, variableOut5 = %s", ...
    dataset, variableIn1, variableIn2, C, dataset, variableOut1, variableOut2, variableOut3, variableOut4, variableOut5);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PD01B", LOGcomment, 0);

[data.(dataset).(variableOut1), data.(dataset).(variableOut2), data.(dataset).(variableOut3), data.(dataset).(variableOut4),LOGcomment] = NormDerivative(data.(dataset).(variableIn1),data.(dataset).(variableIn2), C);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

[data.(dataset).(variableOut5), ~, plot_name, savefigpath, LOGcomment] = plotDifferenceToMean(data.(dataset).(variableOut4),savefigpath);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);
% save the log file for the figure in the folder where the figure is saved.
saveUsedBlocksLog(LOGpath, LOGfile, savefigpath, plot_name);
clear plot_name savefigpath;

% Clear preset variables
clearvars dataset variableIn1 variableIn2 variableIn3 C variableOut1 variableOut2 variableOut3 variableOut4 variableOut5;

%% PC02A Processing-Correcting-02-A; correct the grid for drift 
% Edited by Markus May 2024, Vanessa Nov 2023
% Note: format is updated - gridDriftCorrection() needs to be updated,
% requires a test dataset!

%presets:
datasetGrid ='grid';                %specify the dataset to be used: e.g. grid
variableGrid ='I';                  %specify the variable to be processed: e.g. I
datasetTopoBefore ='topoBefore';    %specify the dataset to be used: e.g. topoBefore
variableTopoBefore ='z';            %specify the variable to be processed: e.g. z
datasetTopoAfter ='topoAfter';      %specify the dataset to be used: e.g. topoAfter
variableTopoAfter ='z';             %specify the variable to be processed: e.g. z
datasetOut ='grid';                 %specify the dataset to return the data to: e.g. grid 
variableOut ='I_driftCorr';         %specify the variable to return the data to: e.g. I (overwrite data) or I_smoothed
theta = 0;                          %angle to rotate the grid (in degrees)

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LOG data in/out:
LOGcomment = sprintf("Grid in: %s.%s; topo before: %s.%s; topo after: %s.%s; data out: %s.%s;",datasetGrid ,variableGrid , datasetTopoBefore, variableTopoBefore, datasetTopoAfter, variableTopoAfter, datasetOut, variableOut);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PC02A", LOGcomment ,0);

%execute function
[data.(datasetOut).(variableOut),LOGcomment] = driftCorrection(data.(datasetGrid).(variableGrid), data.(datasetTopoBefore).(variableTopoBefore), data.(datasetTopoAfter).(variableTopoAfter), theta);
%LOG function call
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);
%ask for plotname and the folder it should be saved in:
targetFolder = uigetdir([],'Choose folder to save the figure to:');
plot_name = uniqueNamePrompt("driftCorrected","",targetFolder);
%LOG saved figure name and dir
LOGcomment = sprintf("Figure saved as (<dir>/<plotname>.fig): %s/%s.fig", targetFolder, plot_name);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

%save the created figures here:
savefig(strcat(targetFolder,"/",plot_name,".fig"))
%create copy of the log corresponding to the saved figures
saveUsedBlocksLog(LOGpath, LOGfile, targetFolder, plot_name);

%clear excess variables that may create issues in other blocks
clearvars datasetGrid variableGrid datasetTopoBefore variableTopoBefore datasetTopoAfter variableTopoAfter datasetOut variableOut
clearvars plot_name targetFolder theta

%% PF01A Processing-Flatten-01-A; Subtracts the plane in topography images
%Edited by Rysa Greenwood Nov 2023, Rysa May 2024
% This section of code subtracts a plane to 'flatten' the image

%presets:
dataset = 'topo'; %specify the dataset to be used
variableIn1= 'x'; % (array) x axis
variableIn2 = 'y'; % (array) y axis
variableIn3 = 'z'; % (array) data
variableIn4 = 'circular_mask'; % optional mask to fit plane to. If no mask desired then variableIn4=''
n = 100; %integer: number of points to sample. Default 200
plot = 1; %boolean: chose to plot the process or not (0: no plot, 1: plot)
variableOut = 'z_flat'; % (array) flattened z data

%%%%%%%%%%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%log input variables
LOGcomment = sprintf("DataIn: dataset = %s, variableIn1 = %s, variableIn2 = %s,  variableIn3 = %s,  variableIn4 = %s; dataOut: variableOut = %s",dataset ,variableIn1 , variableIn2, variableIn3, variableIn4, variableOut);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PF01A", LOGcomment ,0);

%function execution
if isempty(variableIn4)
    [data.(dataset).(variableOut), LOGcomment] = topoPlaneSub(data.(dataset).(variableIn1), data.(dataset).(variableIn2), data.(dataset).(variableIn3), '', n, plot);
else
    [data.(dataset).(variableOut), LOGcomment] = topoPlaneSub(data.(dataset).(variableIn1), data.(dataset).(variableIn2), data.(dataset).(variableIn3), data.(dataset).(variableIn4), n, plot);
end
%plot if desired and LOG data in/out:
if plot
    %ask for plotname:
    plot_name = uniqueNamePrompt("PlaneSub","",LOGpath);
    LOGcomment = strcat(LOGcomment,sprintf(", plotname=%s",plot_name));
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);
    %save the created figures here:
    savefig(strcat(LOGpath,"/",plot_name,".fig"))
    %create copy of the log corresponding to the saved figures
    saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, plot_name);
    clear plot_name;
else
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);
end
%clear variables
clearvars dataset variableIn1 variableIn2 variableIn3 variableOut
clearvars n plot
clearvars plotname

%% PI03A Processing-Image-01-A; apply function to two images (add, subtract, ...)
% Edited by M. Altthaler 2025/04
% This section of code applies a function (add, subtract, multiply, divide) 
% to two images. Masks can be applied to each image. 

% presets:
dataset1 ='topo1';      %specify the 1st dataset to be used: e.g. topo
variableIn1 = 'z';      %specify the variable in the 1st dataset: e.g. z 

dataset2 ='topo2';      %specify the 2nd dataset to be used: e.g. topo
variableIn2 = 'z';      %specify the variable in the 2nd dataset: e.g. z

type = 'subtract';           %specify function to be applied: e.g. 'add' 


% optional variable inputs: [] when unused
% masks
variableIn3 = [];       %specify the mask for the 1st image 
variableIn4 = [];       %specify the mask for the 2nd image

% 3D->2D conversion (only required for grid->energy slice conversion)
%1st image:                               
n1 = [];               % slice number (n-th index of 3rd dim of data) [variableIn5 optional]
variableIn5 = [];      % Voltage axis for the 3D data set: e.g. V_reduced for dIdV or V for I(V)
V_target_1 = [];       % target voltage -> closest value in variableIn2 is chosen [requires variableIn5]

%2nd image:                               
n2 = [];               % slice number (n-th index of 3rd dim of data) [variableIn6 optional]
variableIn6 = [];      % Voltage axis for the 3D data set: e.g. V_reduced for dIdV or V for I(V)
V_target_2 = [];       % target voltage -> closest value in variableIn2 is chosen [requires variableIn6]
     

% return variables: 
variableOut1 = 'combinedImage';     % name of output varibale    

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% LOG data in/out
LOGcomment = sprintf("dataset1 = %s; variableIn1 = %s; dataset2 = %s; variableIn2 = %s; type = %s; variableOut1 = %s;", dataset1, variableIn1, dataset2, variableIn2, type, variableOut1);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PI01A", LOGcomment ,0);
LOGcomment = sprintf("variableIn3 = %s; variableIn4 = %s; n1=%s; variableIn5 = %s; V_target_1=%s, n2=%s; variableIn6 = %s; V_target_2=%s;", variableIn3, variableIn4, mat2str(n1), variableIn5, mat2str(V_target_1), mat2str(n2), variableIn6, mat2str(V_target_2));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

%execute function
[data.(dataset1).(variableOut1), LOGcomment] = twoImagesApplyFunction(requiredStructCall(data,dataset1,variableIn1),requiredStructCall(data,dataset2,variableIn2),type,optionalStructCall(data, dataset1,variableIn3),optionalStructCall(data, dataset2,variableIn4),n1,optionalStructCall(data, dataset1,variableIn5),V_target_1,n2,optionalStructCall(data, dataset2,variableIn6),V_target_2);
data.(dataset2).(variableOut1)=data.(dataset1).(variableOut1); %save image in both datasets

% log the function of excuation 
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

% clear excess variables
clearvars dataset1 dataset2 variableIn1 variableIn2 variableIn3 variableIn4 variableIn5 variableIn6 variableOut1 
clearvars type n1 n2 V_target_1 V_target_2
%% VT01A Visualize-Topo-01-A; visualizes a slice of dI/dV data at a user-defined bias 

% Edited by James October 2023, Jiabin July 2024, Rysa Sept 2024
% This section visualizes a slice of dI/dV data at a user-defined bias. 
% Features:
% 1. Prompt the user for the bias of interest.
% 2. Generate and save the slice plot with appropriate naming.
% 3. Log actions using provided log blocks.


%presets:
dataset ='grid';              %specify the dataset to be used: e.g. grid
variableIn1 = 'dIdV';         %specify the variable data(x,y,V) a V slice is taken from: e.g. didv
variableIn2 = 'V_reduced';    %specify the variable to be processed as the V axis: e.g. V_reduced


% variableOut1 = 'Biases';              % return the function of execution

% Ask the user to enter the bias of interest
bias_of_interest = [-2,0.5,1.5];       %specify the bias voltage (or list of voltages) to select slice, within the range of `variableIn2`


%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% LOG data in/out

LOGcomment = sprintf ("dataset = %s; variableIn1 = %s; variableIn2 = %s; bias_of_interest = %s", dataset, variableIn1, variableIn2, bias_of_interest);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "VT01A", LOGcomment ,0);


% Ask for dir of saving `figure` and the name 
targetFolder = uigetdir([],'Choose folder to save the figure to:');
defaultname = sprintf("bias_slice");
plot_name = uniqueNamePrompt(defaultname, "",targetFolder);

% excute the function
[plot_names,~,LOGcomment] = gridPlotSlices(data.(dataset).(variableIn1),  data.(dataset).(variableIn2), bias_of_interest, plot_name);

% log the function of execution 
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

for plt = 1:length(plot_names)
    % LOG dir/plotname.fig
    LOGcomment = sprintf("Figure saved as (<dir>/<plotname>.fig): %s/%s.fig", targetFolder, plot_names{plt});
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

    % save the figures
    savefig(strcat(targetFolder,"/",plot_names{plt},".fig"));

end

% function: SaveUsedBlocks
saveUsedBlocksLog(LOGpath, LOGfile, targetFolder, plot_name);

% clear excess variables
clearvars dataset variableIn1 variableIn2
clearvars bias_of_interest targetFolder plot_name defaultname
%% VT03A Visualize-Topo-01-A; 2D Image Plotting (topography or grid slice)
% This section of code generates a 2D image of data using the specified layout format.
% The layout can be 'gridsliceImage' or 'topoImage'. The image will be saved to a specified folder.

%Dong Chen 2024; M. Altthaler 2024/12; Jisun 2025/4

% Presets:
LayoutCase = 'gridsliceImage';   % specify the layout format: gridsliceImage or topoImage
dataset = 'grid';           % specify the dataset to be used: e.g. grid, topo
variableIn1 = 'dIdV';           % specify the variable containing the data to be plotted: e.g. z, dIdV

% optional variable inputs
% set values to [] if not used
% Relevant inputs for slicing 3D -> 2D data:
n = [];                         % slice number (n-th index of 3rd dim of data) [variableIn2 optional]
variableIn2 = 'V_reduced';      % Voltage axis for the 3D data set: e.g. 'V_reduced' for dIdV or 'V' for I(V)
imageV = 0.02;  

% define the folder where the created figure to be saved
savefigpath = '';   % If you choose '', it will pop up a window for a user to select the folder to save the figure.
                    % Or you can just directly put a path here: e.g. savefigpat = LOGpath. This must be string.

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% LOG data in/out
LOGcomment = sprintf("LayoutCase = %s; dataset = %s; variableIn1 = %s; n = %s; variableIn2 = %s; imageV = %s; ", LayoutCase, dataset, variableIn1, num2str(n), variableIn2, num2str(imageV));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "VT03A", LOGcomment, 0);

% Execute the function
[data.(dataset).figureHandle, data.(dataset).plotName, data.(dataset).savePath, LOGcomment] = plot2DImage(LayoutCase, data.(dataset).(variableIn1), savefigpath, n, optionalStructCall(data, dataset,variableIn2), imageV);

% Log the execution of the function
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

% Save the figure
savefigpath = data.(dataset).savePath;
plot_name = data.(dataset).plotName;

% LOG dir/plotname.fig
LOGcomment = sprintf("Figure saved as (<dir>/<plotname>.fig): %s/%s.fig", savefigpath, plot_name);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

% Save the figure path to log
saveUsedBlocksLog(LOGpath, LOGfile, savefigpath, strcat(plot_name));

% Clear excess variables
clearvars LayoutCase dataset variableIn savefigpath plot_name

%% VS01A Visualize-Spectrum-01-A; plot average I-V or average dI/dV
% Edited by Jisun Kim Oct 2023, again in Feb 2024, Dong Chen June 2024, Jisun Kim July and Dec 2024
% This section of code plots average I versus V or average dI/dV versus V.
% You have an option to plot forward I (or dIdV) and backward I (or dIdV) separately but together in one plot.

% Presets
% Define dataset and input/output variables here
dataset = 'grid';           % specify which dataset to be used: e.g. grid
variableIn1 = 'V_reduced';  % specify the first input variable, x axis. V for I-V plot and V_reduced for dIdV plot
variableIn2 = 'avg_dIdV';   % specify the second input variable, y axis: e.g. avg_IV or avg_dIdV. You need to run PA02A first. 
                          % Match it to what you process in PA02A.

% optional variable input, set value to [] if not used
variableIn3 = [];    % If you want to plot forward and backward separtely but together in one plot, varialbeIn2 and variableIn3 should be 
                     % specified accordingly. e.g. variableIn2 = avg_IV, variableIn3 = avg_IV_bwd; variableIn2 = avg_dIdV, variableIn3 = avg_dIdV_bwd.                          

% define the folder where the created figure to be saved
savefigpath = '';   % If you choose '', it will pop up a window for a user to select the folder to save the figure.
                    % Or you can just directly put a path here: e.g. savefigpat = LOGpath. This must be string.

LayoutCase = 'dIdV'; % Both LayoutCase 'IV_fwdbwd' and 'dIdV_fwdbwd' assume that variableIn2 is for fwd and varialbeIn3 for bwd.
                            % If you put bwd data as varialbeIn2 and fwd data as variableIn3, the label will be incorrect (reversed). 
%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Log input and output variables 
LOGcomment = sprintf("DataIn: dataset = %s, variableIn1 = %s, variableIn2 = %s, variableIn3 = %s",...
    dataset, variableIn1, variableIn2, variableIn3);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "VS01A", LOGcomment, 0);

if isempty(variableIn3)
    % This makes the averaged "I versus V" plot
    [~, plot_name_1, savefigpath, LOGcomment] = plotOneXYGraph(LayoutCase, data.(dataset).(variableIn1), data.(dataset).(variableIn2), savefigpath);
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

    % create a copy of the log corresponding to the saved figure
    saveUsedBlocksLog(LOGpath, LOGfile, savefigpath, plot_name_1);

else
    % This plots "avg_IV_fwd vs V" and "avg_IV_bwd vs V" in one graph
    [~, plot_name_2, savefigpath, LOGcomment] = plotTwoXYGraph(LayoutCase, data.(dataset).(variableIn1),data.(dataset).(variableIn2), data.(dataset).(variableIn3), savefigpath);
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);
    
    % create a copy of the log corresponding to the saved figure
    saveUsedBlocksLog(LOGpath, LOGfile, savefigpath, plot_name_2);
end
  
% Clear preset variables
clearvars dataset variableIn1 variableIn2 variableIn3 savefigpath plot_name_1 plot_name_2 LayoutCase;
%% VS02A Visualize-Spectrum-02-A; allows you to click on a grid/topo and plot the spectra
% Edited by: James Day January 2025, M. Altthaler June 2024, Vanessa October 2023
% This section of the code opens a GUI that allows you to click
% point(s) on a grid and plot the spectra.
%
% NOTE: Plots dIdV(V) curves. Requires matching V (V_reduced) as voltage axis input.

% Presets:
dataset = 'grid';                % Specify the dataset to be used: e.g., grid
variableIn1 = 'dIdV';            % Specify the variable data(x, y, V) a V slice is taken from: e.g., didv
variableIn2 = 'V_reduced';       % Specify the variable to be processed as the V axis: e.g., V_reduced
imageV = 0.4;                   % Specify the voltage of the dI/dV slice to be displayed
offset = 0;                      % Vertical offset for each point spectrum
n = 4;                           % Number of points to be selected for the plot (ignored if pointsList is provided)
pointsList = [];                 % Set to [] for interactive clicking, or define a matrix for predefined points.

% Define a pointsList (optional):
% If you want to supply a list of points rather than clicking on the grid, uncomment the following lines and define your points:
% pointsList = [
%    13, 41;  % First point
%    25, 25;  % Second point
%    75, 36;   % Third point
% ];

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOG data in/out:
LOGcomment = sprintf("DataIn: dataset = %s, variableIn1 = %s, variableIn2 = %s", dataset, variableIn1, variableIn2);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "VS02A", LOGcomment, 0);

% Execute the `clickForSpectrum` function
try
    % Check if pointsList is empty or predefined
    if isempty(pointsList)
        % Interactive clicking (default behavior)
        LOGcomment = clickForSpectrum(data.(dataset).(variableIn1), data.(dataset).(variableIn2), imageV, offset, n);
    else
        % Use predefined pointsList
        LOGcomment = clickForSpectrum(data.(dataset).(variableIn1), data.(dataset).(variableIn2), imageV, offset, size(pointsList, 1), pointsList);
    end
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

    % Ask for the plot name and the folder to save it in
    targetFolder = uigetdir([], 'Choose folder to save the figure to:');
    plot_name = uniqueNamePrompt("clickedSpectrum", "", targetFolder);

    % LOG saved figure name and dir
    LOGcomment = sprintf("Figure saved as (<dir>/<plotname>.fig): %s/%s.fig", targetFolder, plot_name);
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

    % Save the created figure here
    savefig(strcat(LOGpath, "/", plot_name, ".fig"));

    % Create a copy of the log corresponding to the saved figure
    saveUsedBlocksLog(LOGpath, LOGfile, targetFolder, plot_name);

    % Clear variables to avoid conflicts
    clearvars dataset variableIn1 variableIn2 imageV n offset pointsList targetFolder plot_name
catch ME
    % Handle unexpected errors gracefully
    disp("An error occurred during point selection or spectrum plotting:");
    disp(ME.message);
    disp("Plots will not be saved.");
end


%% VS04A Visualize-Spectra-04-A: Unified Plotting of I/V and dI/dV Profiles
% This script visualizes I/V and dI/dV profiles, automatically determining the layout for display.
% The user can define the step size for profile plotting, enhancing custom visualization.
% Adjusted to automatically determine layout case inside the function.
%
% Edited by James March 2024, James July 2024

% Presets:
dataset = 'grid';   % specify the dataset to be used; e.g, grid
variableIn1 = 'I_smoothed'; % specify the variable to be processed; e.g., IV or dIdV array
variableIn2 = 'V'; % specify the variable to be processed; e.g., voltage or reduced voltage array
variableIn3 = 'avg_IV'; % specify the variable to be processed; e.g., averaged IV or dIdV array

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Display the grid dimensions, so the user sees the scale of the data.
numx = size(data.(dataset).(variableIn1), 1);
numy = size(data.(dataset).(variableIn1), 2);
disp(['Grid dimensions: numx = ', num2str(numx), ', numy = ', num2str(numy)]);

% Prompt user for the step size in profile plotting.
step_size = input('Enter the step size for plotting profiles: ');

% Plot the I/V or dI/dV profiles and log the process
[figName, comment] = plotSpectraProfiles(data.(dataset).(variableIn1), data.(dataset).(variableIn2), data.(dataset).(variableIn3), step_size, numx, numy, LOGpath, "transparent_profiles");

% Log the profile plot
LOGcomment = sprintf("DataIn: %s.%s %s.%s %s.%s; DataOut: %s", dataset, variableIn1, dataset, variableIn2, dataset, variableIn3, figName);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "VS04A", LOGcomment, 0);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", comment, 0);

% Log the saved figures
saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, strcat(figName));

% Clear preset variables
clearvars dataset variableIn1 variableIn2 variableIn3 figName step_size numx numy;
%% VG01A Visualize-Grid-01-A: gridslice viewer for all grids (including the non-square one)
% Edited by Jiabin Nov 2024.
% This section processes 3D dIdV data into image slices and visualizes the stack.

% Prompt for range type selection
%   Dynamic range adjusts the contrast of each image slice individually, 
        % based on: mean(xy laer) +- 8*std(xy layer).
%   Global range applies a consistent color scale across all slices, 
        % using the global minimum and maximum values.

%presets:
dataset = 'grid'; %specify the dataset to be used
variableIn1 = 'dIdV_smoothed'; %specify the variable data(x,y,V) a V slice is taken from: e.g. dIdV
variableIn2 = 'points'; %specify the variable to be processed as the number of slice cuts
variableIn3 = 'invgray'; %specify the colormap to be used
    % Common MATLAB colormaps include:
    % - 'parula' (default MATLAB colormap)
    % - 'jet' (classic rainbow colormap)
    % - 'hsv' (circular color spectrum)
    % - 'cool' (cyan to magenta)
    % - 'hot' (black-red-yellow-white)
    % - 'gray' (grayscale)
    % - 'bone' (gray with a blue tinge)
    % - 'copper' (dark to light copper tone)
nestedStructure = true; % Set to true if variableIn2 is nested under 'header'

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

while true
    rangeChoice = upper(input('Select color range type you want (G/g for Global, D/d for Dynamic): ', 's'));
    if strcmp(rangeChoice, 'G')
        rangeType = 'global';
        break;
    elseif strcmp(rangeChoice, 'D')
        rangeType = 'dynamic';
        break;
    else
        fprintf('Invalid selection. Please enter G or D.\n');
    end
end

% LOG data in/out
LOGcomment = sprintf("dataset = %s; variableIn1 = %s; variableIn2 = %s; variableIn3 = %s; nestedStructure = %s; rangeType = %s", ...
    dataset, variableIn1, variableIn2, variableIn3, mat2str(nestedStructure), rangeType);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "VG01A", LOGcomment, 0);

% Prepare input data
inputData1 = data.(dataset).(variableIn1);
if nestedStructure
    inputData2 = data.(dataset).header.(variableIn2);
else
    inputData2 = data.(dataset).(variableIn2);
end


% Cartesian coordinate mapping
gridStackResult = gridSliceViewer(inputData1, inputData2, rangeType, variableIn3);

% Convert gridStackResult to string if it's not already
if ~ischar(gridStackResult) && ~isstring(gridStackResult)
    gridStackResult = jsonencode(gridStackResult);
end

clearvars dataset variableIn1 variableIn2 variableIn3 targetFolder plot_name nestedStructure inputData1 inputData2 gridStackResult