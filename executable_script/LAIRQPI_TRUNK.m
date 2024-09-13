%% This qpiTrunk is made for the QPI data processing
%% List of Blocks 
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


%% PP01A Preprocess-01-A; Preprocess workspace data and perform Fourier transforms
% Edited by Dong Chen, Sep 2024

% This section preprocesses the loaded data for QPI analysis.
% It applies Gaussian smoothing to the current data if requested, processes 
% lock-in data if available, numerically differentiates the current data to 
% obtain dI/dV, and performs Fourier transforms.

% Presets:
sigma = 5; % Standard deviation for Gaussian smoothing; adjust if needed
apply_smoothing = input('Do you want to apply Gaussian smoothing? (1 for yes, 0 for no): '); % Apply smoothing option

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOG data in/out:
LOGcomment = sprintf("Preprocessing workspace data with sigma = %d, apply_smoothing = %d", sigma, apply_smoothing);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PP01A", LOGcomment, 0);

% Preprocess the workspace data and perform Fourier transforms
[data.grid.midV, data.grid.I, data.grid.LockindIdV, ...
 data.grid.dIdV, data.grid.QPI, data.grid.LockinQPI, preprocessComment] = ...
    preProcessWorkspace(data, sigma, apply_smoothing);

% Log the preprocessing details
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", preprocessComment, 0);

% Additional logging for specific preprocessing steps
if ~isempty(data.grid.LockindIdV)
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", "Processed Lock-in data", 0);
else
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", "No Lock-in data processed", 0);
end

LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", "Calculated dI/dV", 0);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", "Performed Fourier transforms on dI/dV and Lock-in data", 0);

clearvars sigma apply_smoothing
