%% Test script for data processing with logging

%% Block logging
    %%   log file info
    
    % every block needs a unique identifier BLOCK (5 char long!) 
    % Format:   ABXXZ
    %      A:   L = loading, P = processing, V = visulalizing
    %      B:   subidentifiers (e.g. A = averaging, P = plot, M = masking, ...) TBD! 
    %     XX:   1, 2, 3, ..., 99 (running number for consecutive blocks)
    %      Z:   a, b, c, ... (alternate abc for either or blocks)

    % Block header format: (every block starts with this line!) 
    % %% ABXXZ Axxx-Bxxx-XX-Z; <short description>
    % note: Axxx stands for the spelled out form: e.g. "L -> Loading". Bxxx
    % is treated the same way. See block list for full examples. 

    % ToDo: a full list of all 'codes' B->Bxxx 

    % The logUsedBlocks() function logs the time and date, block identifyer
    % and a LOGcomment. The LOGcomment must log all functions used in the 
    % block and their (user set) parameters so the data can be reproduced:
    % LOGcomment = "funA(A = parA, B = parB); "
    % If logUsedBlocks()is used multiple times per block to log inividual
    % functions only the first instance logs the blockidentifier (ABXXZ),
    % subsequently: "  ^  " is used as the idetifyer indicating multiple
    % lines in the logfile are from the same block. 

    % If any data output is generated (figures, plots, ...) they must be 
    % saved from the block and saveUsedBlocksLog() must be used to create a
    % duplicate of the log that is saved with the saved data. These log 
    % files allow us to reproduce data with the same verison of the code!
    % If multiple plots are created within one block and the data is 
    % altered in between (e.g. the same function is called multiple times
    % with different parameters) every instace must be logged and saved!
    % E.g. if funA and funB create a plot but alter the data:
    % funA() -> logUsedBlocks(... funA ...) -> saveUsedBlocksLog(... FigA)
    % funB() -> logUsedBlocks(... funB ...) -> saveUsedBlocksLog(... FigB)

    % If a figure, ... is supposed to be saved use the uniqueNamePrompt()
    % function to give it a default name. It automatically allows the user
    % to overwrite the name by the response to the promtp. If a file of the
    % same name already exists a 3 digit running number is appended.
%% Block List
    % LI01A Load-Initialize-01-A; Initializing the log file and choosing the data
    % LI01B Load-Initialize-01-B; Initialize log file, UI select path and name
    % LD01A Load-Data-01-A; Load data (grid, topo, ...) via UI file selection
    % LG01A Load-Grid-01-A; load grid 
    % LG01B Load-Grid-01-B; load grid and topo from Nanonis
    % PA01A Processing-Averaging-01-A; applies moving-average smoothing to I-V
    % PA02A Processing-Averaging-Mask-02-A; average I-V according to a mask
    % PD01A Processing-Derivative-01-A; create a regular dIdV for I-V
    % PD01B Processing-Derivative-01-B; create a nomarlized dIdV (i.e. dIdV/I-V) for all I-V, and forward & backward separately
    % PC02A Processing-Correcting-02-A; correct the grid for drift 
    % PF01A Processing-Flatten-01-A; Subtracts the plane in topography images;
    % PT01A Processing-Threshold-01-A; Gets threshold from the height distribution of topo;
    % VS01A Visualize-Spectrum-01-A; plot I-V or dI/dV
    % VS02A Visualize-Spectrum-02-A; allows you to click on a grid/topo and plot the spectra
    % VS03A Visualize-Spectrum-03-A; circular masking
    % VT01A Visualize-Topo-01-A; visualizes a slice of dI/dV data at a user-defined bias and saves it


%% LI01A Load-Initialize-01-A; Initializing the log file and choosing the data
%   Edited by Markus, August 2023

% This section of code specifies the data paths, and files to be  
% analyzed. The log file is initialized based on the given values. 

% Potentially to be merged with (2) if grid load upwards is updated
% accordingly, to use uigetfile/uigetdir intrinsically. 

% use the pathApp (to be found on the LAIR Git) to add directories of your 
% data and scripts to the MATLAB path. 

% load all necessary script directories
folder = uigetdir();

% stamp_project is the filename leader and takes the form 'yyyymmdd-XXXXXX_CaPt--STM_Spectroscopy--';
stamp_project = '20210308-124244_CaPt--STM_Spectroscopy--'; 

% set the grid I(V) file number
grid_number = '108_1';

% set the z-file (aka topo) image number
img_number = '54_1'; 

% set the dat file (aka spec) number
spec_number = '100'; 

%set LOGfolder and LOGfile 
%*must not be changed during an iteration of data processing!
%*can be set automatically, e.g. when choosing
%only one topo file with uigetfile it automatically appends '_LOGfile' to the
%fiel name given.
LOGpath = folder;
LOGfile = strcat(stamp_project,"_grdNr_",grid_number,"_imgNr_",img_number,"_PpS_");
LOGcomment = "Initializing log file";
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LI01A", LOGcomment, 1);

%% LI01B Load-Initialize-01-B; Initialize log file, UI select path and name
%   Edited by M. Altthaler, April 2024

% This section of code specifies the <paths> and <name> of the LOG file. 
% Subsequently the <path>\<name>_LOGfile.txt is initialized with this information. 
 
%select LOGpath and LOGfile
%choose to run the function with argument 0 or 1!
% 0: UI to choose <paths> and an input prompt for the log file <name>
% 1: UI to select a file, the file <name> and <paths> set the log file 
% Note: _LOGfile.txt will be appended to the chosen name!
[LOGpath,LOGfile] = setLogFile(0);

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


[data, commentA, commentB, commentC] = loadData(data);

%log use of block, and the specific data and field name assigned
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LD01A", commentA, 0);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", commentB, 0);
%LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", commentC, 0);

%% LG01A Load-Grid-01-A; load grid 
% This section of code loads the files called above (grid_number and img_number)

avg_forward_and_backward = false;
[grid,LOGcomment] = gridLoadDataUpward(folder,stamp_project,img_number,grid_number,avg_forward_and_backward); % Taking data Upward
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LG01A", LOGcomment ,0);

%% LG01B Load-Grid-01-B; load grid and topo from Nanonis
%Edited by Vanessa summer 2023
% This section of code loads the files called above if they are Nanonis,

topoDirection='forward';
avg_forward_and_backward = true;
[grid,LOGcomment] = pythonDataToGrid(folder, stamp_project, grid_number, img_number, topoDirection);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LG01B", LOGcomment ,0);

%% LS02A Load-Spectra-01-A; load grid and topo from Nanonis
%Edited by Dong Nov 2023
% This section of code loads the spectra.

[header, data, channels, LOGcomment] = specLoad(folder,stamp_project,spec_number);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LS02A", LOGcomment ,0);

%% PA01A Processing-Averaging-01-A; applies moving-average smoothing to I-V
%Edited by M. Altthaler April 2024; James October 2023; Jisun October 2023

% This section of code applies moving-average smoothing to the I-V data of the grid. 

%presets:
dataset = 'grid';   % specify the dataset to be used: e.g. grid
variableIn = 'I';  % specify the variable to be processed, e.g. I
variableOut = 'I_smoothed'; % specify the variable to return the data to, e.g. I (overwrite data) or I_smoothed
span = 3;       %size of the moving window. E.g. 3: for nearest neighbor averaging; 5 for next nearast neighbor averaging.

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LOG data in/out:
LOGcomment = sprintf("DataIn: %s.%s; dataOut: %s.%s",dataset ,variableIn , dataset, variableOut);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PA01A", LOGcomment ,0);


[data.(dataset).(variableOut), LOGcomment] = smoothData(data.(dataset).(variableIn),span,'IV');
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

% if (~avg_forward_and_backward)
%     [grid.I_Forward,LOGcomment] = gridSmooth(grid.I_Forward,'grid.I_Forward',span);
%     LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0); 
%     [grid.I_Backward,LOGcomment] = gridSmooth(grid.I_Backward,'grid.I_Backward',span);
%     LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);
% end
%% PA02A Processing-Averaging-Mask-02-A; average I-V according to a mask
% Edited by Jisun Kim Oct 2023, again in Feb 2024, Dong Chen June 2024
% This section of code averages the I-V data according to a given mask.

% Presets
% Define dataset and input/output variables here
dataset = 'grid';   % specify the dataset to be used: e.g., grid
variableIn1 = 'I'; % the variable that you want to average. 
variableOut1 = 'avg_iv'; % specify the first output variable

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Log input and output variables
LOGcomment = sprintf("DataIn: dataset = %s, variableIn1 = %s; DataOut: variableOut1 = %s", ...
    dataset, variableIn1, variableOut1);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PMA01A", LOGcomment, 0);

% Main code execution section

% This makes the averaged "I versus V" plot
[~, data.(dataset).(variableOut1), LOGcomment] = avgMaskFast(data.(dataset).(variableIn1));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

% Clear preset variables
clearvars dataset variableIn1 variableOut1;

%% PD01A Processing-Derivative-01-A; create a regular dIdV for I-V. 
% Edited by: Jisun November 2023, again in May 2024

% This section of code creates a regular dIdV data from the grid. It will create dIdV for I-V

%presets:
dataset = 'grid';   % specify the dataset to be used: e.g. grid
variableIn1 = 'I_smoothed'; % specify the variable to be processed, e.g. I, I_Forward, or I_Backward
                            % this is a 3d array form (x, y, V)
variableIn2 = 'V'; % specify the variable to be processed, e.g. V or Z
                   % this is a 1d array form (V ,1)
variableOut1 = 'dIdV'; % specify the variable to return the data to
                       % this is a 3d array form (x, y, V-1)
variableOut2 = 'V_reduced'; % specify the variable to return the data to
                            % this is a 3d array form (x, y, V-1)
%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LOG data in/out:
LOGcomment = sprintf("DataIn: dataset = %s, variableIn1 = %s, variableIn2 = %s; dataOut: dataset = %s, variableOut1 = %s, variableOut2 = %s",dataset, variableIn1, variableIn2, dataset, variableOut1, variableOut2);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PD01A", LOGcomment ,0);

[data.(dataset).(variableOut1), data.(dataset).(variableOut2), LOGcomment] = Derivative(data.(dataset).(variableIn1),data.(dataset).(variableIn2));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

clearvars dataset  
clearvars variableIn1 variableIn2 
clearvars variableOut1 variableOut2 
%% PD01B Processing-Derivative-01-B; create a nomarlized dIdV (i.e. dIdV/I-V) for all I-V, and forward & backward separately. 
% When you run this section, your didv becomes/means normalized didv 
% and your grid.I becomes/means offset corrected I (see gridNormDerivative for details).
% Edited by: Jisun November 2023

% This section of code creates a normalized dIdV data from the grid. It will create dIdV for all I-V; foward only; backward only. 
C=3E-10;
[didv, grid.I, V_reduced, I_offset, LOGcomment] = gridNormDerivative(grid, C);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PD02A", LOGcomment ,0);

[I_offset_std, f, plot_name, LOGcomment] = plotDifferenceToMean(I_offset, LOGpath);
saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, plot_name);
clear plot_name;
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);


if (~avg_forward_and_backward)
    gridForward = grid;
    [gridForward.I] = gridForward.I_Forward;
    [didv_forward, grid.I_Forward, ~, ~, LOGcomment] = gridNormDerivative(gridForward, C);
    LOGcomment = strcat("Forward_",LOGcomment);
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);
    
    gridBackward = grid;
    [gridBackward.I] = gridForward.I_Backward;
    [didv_backward, grid.I_Backward, ~, ~, LOGcomment] = gridNormDerivative(gridBackward, C);
    LOGcomment = strcat("Backward_",LOGcomment);
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);
end

%% PC02A Processing-Correcting-02-A; correct the grid for drift 
% Edited by Vanessa Nov 2023
% TO DO: have it actually take in two different topos. Make a new block
% just for loading individual topos without a corresponding grid? 

before = grid.z_img;
after = grid.z_img;
theta = 0;
[grid,LOGcomment] = gridDriftCorrection(grid, before, after, theta);

%ask for plotname:
plot_name = uniqueNamePrompt("driftCorrected","",LOGpath);
LOGcomment = strcat(LOGcomment,sprintf(", plotname=%s",plot_name));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PC02A", LOGcomment ,0);

%save the created figures here:
savefig(strcat(LOGpath,"/",plot_name,".fig"))

%create copy of the log corresponding to the saved figures
saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, plot_name);
clear plot_name;


%% PF01A Processing-Flatten-01-A; Subtracts the plane in topography images;
%Edited by Rysa Greenwood Nov 2023, Rysa May 2024
% This section of code subtracts a plane to 'flatten' the image

%presets:
dataset = 'topo'; %specify the dataset to be used
variableIn1= 'x'; % (array) x axis
variableIn2 = 'y'; % (array) y axis
variableIn3 = 'z'; % (array) data
n = 100; %integer: number of points to sample. Default 200
plot = 1; %boolean: chose to plot the process or not (0: no plot, 1: plot)
variableOut = 'z_flat'; % (array) flattened z data

%%%%%%%%%%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%log input variables
LOGcomment = sprintf("DataIn: dataset = %s, variableIn1 = %s, variableIn2 = %s,  variableIn2 = %s; dataOut: variableOut = %s",dataset ,variableIn1 , variableIn2, variableIn3, variableOut);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PF01A", LOGcomment ,0);
%function execution
[data.(dataset).(variableOut), LOGcomment] = topoPlaneSub(data.(dataset).(variableIn1), data.(dataset).(variableIn2), data.(dataset).(variableIn3), n, plot); %need to fix function
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

%% PT01A Processing-Threshold-01-A; Gets threshold from the height distribution of topo;
%Edited by Rysa Greenwood Nov 2023
%Need to run LI01A, LG01A first. Suggest running PF01A aswell. Right now this can only handle topo images
%from grid structure
%arguments:
% topo (struct): grid

image = topo;

[topoThresh, LOGcomment] = topoGetThreshold(image);

%ask for plotname:
plot_name = uniqueNamePrompt("TopoThresh","",LOGpath);
LOGcomment = strcat(LOGcomment,sprintf(", plotname=%s",plot_name));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PT01A", LOGcomment ,0);

%save the created figures here:
savefig(strcat(LOGpath,"/",plot_name,".fig"))

%create copy of the log corresponding to the saved figures
saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, plot_name);
clear plot_name;

%% VS01A Visualize-Spectrum-01-A; plot I-V or dI/dV
% Edited by Jisun Kim Oct 2023, again in Feb 2024, Dong Chen June 2024
% This section of code plots I versus V, dI/dV versus V for all I-V curves.
% NOTE: IF I DON'T RUN PD01A or PD01B, THIS SECTION DOESN'T RECOGNIZE V_reduced

% Presets
% Define dataset and input/output variables here
dataset = 'grid';   % specify which dataset to be used: e.g., grid
variableIn1 = 'V'; % specify the first input variable, x axis.
variableIn2 = 'avg_iv'; % specify the second input variable, y axis.

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Log input and output variables
LOGcomment = sprintf("DataIn: dataset = %s, variableIn1 = %s, variableIn2 = %s", ...
    dataset, variableIn1, variableIn2);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "VS01A", LOGcomment, 0);

% Main code execution section

% This makes the averaged "I versus V" plot
[~, plot_name_1, LOGcomment] = plotOneXYGraph(LOGpath, "IV", data.(dataset).(variableIn1), data.(dataset).(variableIn2));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

% Example of creating a copy of the log corresponding to the saved figures
saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, strcat(plot_name_1));

% Clear preset variables
clearvars dataset variableIn1 variableIn2 plot_name_1;
%% VS02A Visualize-Spectrum-02-A; allows you to click on a grid/topo and plot the spectra
% Edited by Vanessa October 2023
% This section of the code opens a GUI that allows you to click
% point(s) on a grid and plot the spectra
%
% NOTE: IF I DON'T RUN PC01A, THIS SECTION DOESN'T RECOGNIZE V_reduced

imageV = 0.6; %float, Voltage at which to display grid slice in no topo is provided
n=1; %integer, Number of point spectra to plot
offset=0; %Vertical offset for each point spectra 
xysmooth=0.0; %float, the standard deviation of a Gaussian for smoothing xy pixels (0 is no smoothing)
vsmooth=0.0; %float, the standard deviation of a Gaussian for smoothing the voltage sweep points (0 is no smoothing)


LOGcomment = gridClickForSpectrum(didv, V_reduced, imageV, n, offset, xysmooth, vsmooth, grid);

%ask for plotname:
plot_name = uniqueNamePrompt("clickedSpectrum","",LOGpath);
LOGcomment = strcat(LOGcomment,sprintf(", plotname=%s",plot_name));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "VS02A", LOGcomment ,0);

%save the created figures here:
savefig(strcat(LOGpath,"/",plot_name,".fig"))

%create copy of the log corresponding to the saved figures
saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, plot_name);
clear plot_name;

%% VS03A Visualize-Spectrum-03-A; circular masking;

% Edited by Jiabin May 2024; Jisun Oct 2023, again in Feb 2024.
% This section of code creates a circular mask of radius R around a clicked point. 
% It then plots the average dI/dV on that point. The user may toggle R and energy slice.

%presets:
dataset ='grid';              %specify the dataset to be used: e.g. grid
variableIn1 = 'didv';         %specify the variable data(x,y,V) a V slice is taken from: e.g. didv
variableIn2 = 'V_reduced';    %specify the variable to be processed as the V axis: e.g. V_reduced

variableOut1 = 'circular_mask';              % return the function of excuation
variableOut2 = 'Num_in_mask';

imageV = 0.15;  % bias voltage of image slice
radius = 3;     % radius R 

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% LOG data in/out
LOGcomment = sprintf("dataset = %s; variableIn1 = %s; variableIn2 = %s; variableOut1 = %s; variableOut2 = %s; ", dataset, variableIn1,variableIn2, variableOut1, variableOut2);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "VS03A", LOGcomment ,0);

% excute the function
[data.(dataset).(variableOut1), data.(dataset).(variableOut2), LOGcomment] = gridMaskPoint(data.(dataset).(variableIn1),  data.(dataset).(variableIn2), imageV, radius);

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

%% VT01A Visualize-Topo-01-A; visualizes a slice of dI/dV data at a user-defined bias and saves it
% Edited by James October 2023

% This section visualizes a slice of dI/dV data at a user-defined bias. 
% Features:
% 1. Prompt the user for the bias of interest.
% 2. Generate and save the slice plot with appropriate naming.
% 3. Log actions using provided log blocks.

% Ask the user to enter the bias of interest
bias_of_interest = input("Enter the bias of interest: ");

% Convert the bias_of_interest to string if it's a number
bias_str = num2str(bias_of_interest);

% Generate the first plot and return a LOGcomment
plot_name_cell = {uniqueNamePrompt("bias_slice_" + bias_str, "", LOGpath)};
[Biases,LOGcomment] = gridPlotSlices(didv, V_reduced, bias_of_interest, plot_name_cell);

% Naming and saving the first figure
filename = sprintf('%s/%s.fig', LOGpath, plot_name_cell{1});
savefig(filename);
LOGcomment = strcat(LOGcomment,sprintf(", plotname=%s",plot_name_cell{1}));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "VT01A", LOGcomment, 0);

% Create copy of the log corresponding to the saved figures
saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, plot_name_cell{1});
clear plot_name_cell;

clear plot_name_cell;

%% PT02A Processing-Transforming-01-A: Transforms Flat-Style Matrix Data to Nanonis Array-Style
% This script converts Matrix-style data, typically used in generic processing, to
% the array-style format used by Nanonis systems, facilitating compatibility and further analysis.
%
% Edited by James December 2023; James May 2024

% This section of code transforms the grid and dI/dV data, from Matrix format to Nanonis-style arrays.

% Presets:
dataset = 'grid';   % specify the dataset to be used; e.g, grid
variableIn = 'didv';  % specify the variable to be processed; e.g., didv
variableOut1 = 'IV_NanonisStyle'; % specify the variable to return the data to; e.g., Nanonis-style IV array
variableOut2 = 'dIdV_NanonisStyle'; % specify the variable to return the data to; e.g., Nanonis-style dIdV array
variableOut3 = 'avg_IV_NanonisStyle'; % specify the variable to return the data to; e.g., Nanonis-style averaged IV array
variableOut4 = 'avg_dIdV_NanonisStyle'; % specify the variable to return the data to; e.g., Nanonis-style averaged dIdV array

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOG data in/out:
LOGcomment = sprintf("DataIn: %s.%s; DataOut: %s.%s %s %s %s", dataset, variableIn, dataset, variableOut1, variableOut2, variableOut3, variableOut4);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PT02A", LOGcomment ,0);

% Main code execution section
% Transform Matrix-style data to Nanonis-style arrays
[data.(dataset).(variableOut1), data.(dataset).(variableOut2), data.(dataset).(variableOut3), data.(dataset).(variableOut4), LOGcomment] = matrixToNanonis(data.(dataset), data.(dataset).(variableIn));

% LOG data out:
LOGcomment = strcat("Transform to Nanonis style data");
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

% Clear preset variables
clearvars dataset variableIn variableOut1 variableOut2 variableOut3 variableOut4;

%% VS04A Visualize-Spectra-04-A: Unified Plotting of I/V and dI/dV Profiles
% Adjusted to automatically determine layout case inside the function.
% Edited by James March 2024

% Display grid dimensions to the user
numx = size(IV_NanonisStyle, 1);
numy = size(IV_NanonisStyle, 2);
disp(['Grid dimensions: numx = ', num2str(numx), ', numy = ', num2str(numy)]);

% User input for step size in profile plotting
step_size = input('Enter the step size for plotting profiles: ');

% Assuming IV_NanonisStyle and dIdV_NanonisStyle have been defined elsewhere
[figNameIV, commentIV] = plotSpectraProfiles(IV_NanonisStyle, grid.V, avg_IV_NanonisStyle, step_size, numx, numy, LOGpath, "transparent_IV");
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "VS04D", commentIV, 0);

[figNameDIDV, commentDIDV] = plotSpectraProfiles(dIdV_NanonisStyle, V_reduced, avg_dIdV_NanonisStyle, step_size, numx, numy, LOGpath, "transparent_dIdV");
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", commentDIDV, 0);