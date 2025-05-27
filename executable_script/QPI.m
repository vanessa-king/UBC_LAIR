%% Script for QPI processing with logging

%% Block logging

% This section outlines the guidelines for naming and logging each block in the code.

% 1. Block Identifier Format
%    Each block must have a unique 5-character identifier of the form: ABXXZ
%       - A:   Category of the block:
%               Q = QPI (fixed for all blocks in this script!)
%       - B:   Subcategory of the block, based on the task being performed:
%              Examples (based on block list as of Oct 2024): 
%               C = Compute
%               *NOTE* do not double up on masking e.g. (use block in mainTrunk)
%       - XX:  Running number for consecutive blocks (01, 02, ..., 99)
%       - Z:   Alternating letter for variations of a block (a, b, c, ...)

% 2. Block Header Format
%    Each block starts with a block header in this format:
%       %% ABXXZ Axxx-Bxxx-XX-Z; <short description of the blocks function>
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


% This log file and block naming system ensures reproducibility and proper %% Block List

%% Block List 
% QPI Processing Blocks:
% 
% Compute:
% QC01A QPI-Compute-01-A: Compute QPI from dIdV/Lockin dIdV data
%
% Visualize:
% QV01A QPI-Visualize-01-A: 3D visualize QPI 
% QV02A QPI-Visualize-02-A: Make 2D slice from 3D QPI dataset
% QV03A QPI-Visualize-03-A: Create rotational slices from 3D data
%
% Process:
% QN01A QPI-Normalize-01-A: Normalize dIdV data
% QP01A QPI-Process-01-A: Filter in q-space
% QP02A QPI-Process-02-A: Streak removal - Global streaks
% QP02B QPI-Process-02-B: Streak removal - Local directional streaks
% QP04A QPI-Process-04-A: Defect masking using Gaussian suppression
% QP05A QPI-Process-05-A: Square cropping (Optional, main trunk has crop)
%
% Select:
% QS01A QPI-Select-01-A: Create and apply center-symmetric mask in q-space

% QPI Processing ****(MUST!)****
% ; Bragg Align(100-109)-> means you can locate this in QPI_mean_historical.m (from line - to line)
% ; Data Symmetrize(wishlist: symmetry under an operation)(123-135)
% ; 2D Slice from 3D data - energy or spatial(testScript_volumeSlicedView_historical.m)

% Pre-QPI grid processing (No Need here, go Main_Trunk)
% ; DriftCorr(wishlist) & Crop grid(32-38)
% ; Streaks Remove(39-50)
% ; Defect Masking(51-72)
% Theory processing 
% ; Load the Theory calculation(now only support DFT)(393-406)
% ; JDOS calculation(414-432)
% QPI Visualization(Maybe Main_Trunk)
% ; Grid/QPI 3D Viewer/Printout(default False)
% ; QPI/JDOS/DFT slice 2D Viewer/Printout(default False)


%% QN01A QPI-Normalize-01-A: Normalize dIdV data
% Created by Dong Chen in May 2025
%
% This section normalizes the dIdV data by removing background and setting mean to zero.
% The normalization process:
% - Removes background trend
% - Sets mean value to zero for each slice
% - Can be applied to specific slices or the entire dataset
%
% presets:
dataset = 'grid';           % specify the dataset to be used: e.g. grid
variableIn = 'dIdV';        % specify the input variable (dIdV data)
variableOut = 'dIdV_normalized'; % specify the variable name to store the normalized data
param1 = 'global';         % range type: 'global' (all slices) or 'slice' (individual slices)
param2 = '';               % optional: specific slice indices to normalize, if empty normalizes all slices

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOG data in/out:
LOGcomment = sprintf("Normalize DataIn: %s.%s; and get dataOut: %s.%s", ...
    dataset, variableIn, dataset, variableOut);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "QN01A", LOGcomment, 0);

% Get input data
inputData = data.(dataset).(variableIn);

% Normalize data
[data.(dataset).(variableOut), LOGcomment] = normalizeBackgroundToZeroMean3D(inputData, param1, param2);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", sprintf("normalizeBackgroundToZeroMean3D(dIdV, '%s', %s)", param1, mat2str(param2)), 0);

% Clean up variables
clearvars dataset variableIn variableOut inputData param1 param2

%% QC01A QPI-Compute-01-A; Compute QPI from dIdV/Lockin dIdV data
% Created by Dong Chen in Apr 2025
%
% This section computes the Quasiparticle Interference (QPI) patterns by 
% performing Fourier transforms on dI/dV or Lockin dI/dV data.
%
% The QPI calculation:
% - Removes mean value to eliminate zero frequency spike
% - Performs 2D FFT on each energy slice
% - Centers zero frequency using fftshift
% - Takes absolute value for intensity mapping
 
% presets:
dataset = 'grid';           % specify the dataset to be used: e.g. grid
variableIn = 'dIdV_normalized';       % specify the input variable (dIdV or LockindIdV)   
variableOut = 'QPI';       % specify the variable name to store the QPI data

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOG data in/out:
LOGcomment = sprintf("Create QPI data from DataIn: %s.%s; and get dataOut: %s.%s", ...
    dataset, variableIn, dataset, variableOut);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "QC01A", LOGcomment, 0);

% Get input data
inputData = data.(dataset).(variableIn);

% Calculate QPI
[data.(dataset).(variableOut), LOGcomment] = qpiCalculate(inputData);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

% Clean up variables
clearvars dataset variableIn variableOut inputData


%% QV01A QPI-Visualize-01-A: 3D visualize QPI 
% Created by Dong Chen in May 2025
%
% This section visualize the 3D QPI datablock, it does not output anything
 
% presets:
dataset = 'grid';           % specify the dataset to be used: e.g. grid
variableIn1 = 'QPI';       % specify the input variable (dIdV or LockindIdV)   
param1 = 'dynamic';      % choose contrast range of each slice, 'global': [global min, global max] vs 'dynamic': [slice min, slice max].

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get input data
inputData = data.(dataset).(variableIn1);

% display QPI
figure;
d3gridDisplay(inputData, param1);

% Clean up variables
clearvars dataset variableIn1 param1


%% QV02A QPI-Visualize-02-A: Make 2D slice from 3D QPI dataset
% Created by Dong Chen in May 2025
% 
% This section let users cut a vertical 2D slice from the 3D dataset. 
 
% presets:
dataset = 'grid';           % specify the dataset to be used: e.g. grid
variableIn1 = 'QPI';       % specify the input variable (dIdV or LockindIdV)   
param1 = 'segment';         % cut with "line" or "segment"(line segment)
param2 = 'global';         % contrast modes: 'dynamic': contrast normalized for each energy, 'global': global contrast for all energies
variableIn2 = [];           % optional, input mask 
variableOut1 = 'QPI_slices';       % specify the variable name to store the QPI data
variableOut2 = 'QPI_slice_mask';  % output mask

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOG data in/out:
LOGcomment = sprintf("From QPI in: %s.%s; and get 2D slice in dataOut: %s.%s, given mask: %s", ...
    dataset, variableIn1, dataset, variableOut1, variableOut2);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "QC01A", LOGcomment, 0);

% Get input data
inputData = data.(dataset).(variableIn1);

% Calculate QPI
[data.(dataset).(variableOut1), data.(dataset).(variableOut2), LOGcomment] = d3sliceviewer(inputData, param1, param2, optionalStructCall(data,dataset,variableIn2));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

% Clean up variables
clearvars dataset variableIn variableOut inputData

%% QV03A QPI-Visualize-03-A: Create rotational slices from 3D data
% Created by Dong Chen in May 2025
%
% This section creates 2D slices from 3D data by rotating a line through the center.
% The process:
% - Allows user to adjust a circle to determine line length
% - Creates slices by rotating the line through 180 degrees
% - Displays both original data with rotating line and the slice data
% - Provides interactive angle selection via slider
%
% presets:
dataset = 'grid';           % specify the dataset to be used: e.g. grid
variableIn = 'QPI';         % specify the input variable (QPI data)
variableOut1 = 'rotational_slices'; % specify the variable name to store the slice data
variableOut2 = 'slice_angles'; % specify the variable name to store the angles
param1 = 'dynamic';         % range type: 'dynamic' (normalized per slice) or 'global'
param2 = 1;                 % line width in pixels

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOG data in/out:
LOGcomment = sprintf("Create rotational slices from DataIn: %s.%s; and get dataOut: %s.%s and %s.%s", ...
    dataset, variableIn, dataset, variableOut1, dataset, variableOut2);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "QV03A", LOGcomment, 0);

% Get input data
inputData = data.(dataset).(variableIn);

% Create rotational slices
[data.(dataset).(variableOut1), data.(dataset).(variableOut2)] = rotational_slices(inputData, param1, param2);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", sprintf("rotational_slices(QPI, '%s', %d)", param1, param2), 0);

% Clean up variables
clearvars dataset variableIn variableOut1 variableOut2 inputData param1 param2

%% QS01A QPI-Select-01-A: Create and apply center-symmetric mask in q-space
% Created by Dong Chen in May 2025
%
% This section creates a center-symmetric mask in q-space and apply it to the QPI data.
% Users can select regions using either circular or rectangular ROIs.
% The mask is automatically mirrored across the center point.
% Two mask modes are available:
% - Binary mask (1 for unmasked, 0 for masked regions)
% - Gaussian window (smooth transition with specified sigma)
% Two operation modes are available:
% - Remove: removes the masked regions (default)
% - Select: keeps only the masked regions
%
% presets:
dataset = 'grid';           % specify the dataset to be used: e.g. grid
variableIn = 'dIdV';        % specify the input variable (real-space grid data)
variableOut1 = 'dIdV_masked'; % specify the variable name to store the masked real-space data
variableOut2 = 'QPI_masked'; % specify the variable name to store the masked QPI data
variableOut3 = 'QPI_mask';   % specify the variable name to store the mask
slice_idx = [];            % optional: specify slice index, if empty will show full 3D dataset
param1 = 'gaussian_window'; % mask mode: 'binary' or 'gaussian_window'
param2 = 2;                % sigma for gaussian window (only used if param1 is 'gaussian_window')
param3 = 'remove';         % operation mode: 'remove' or 'select'

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOG data in/out:
LOGcomment = sprintf("Create QPI mask from DataIn: %s.%s; and get dataOut: %s.%s, %s.%s, and %s.%s", ...
    dataset, variableIn, dataset, variableOut1, dataset, variableOut2, dataset, variableOut3);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "QS01A", LOGcomment, 0);

% Get input data
inputData = data.(dataset).(variableIn);

% Create mask and apply it
if strcmp(param1, 'binary')
    [data.(dataset).(variableOut3), data.(dataset).(variableOut1), data.(dataset).(variableOut2), LOGcomment] = qpiMask(inputData, slice_idx, 'binary', [], param3);
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", sprintf("qpiMask(grid_data(:,:,%d), %d, 'binary', [], '%s')", slice_idx, slice_idx, param3), 0);
else
    [data.(dataset).(variableOut3), data.(dataset).(variableOut1), data.(dataset).(variableOut2), LOGcomment] = qpiMask(inputData, slice_idx, 'gaussian_window', param2, param3);
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", sprintf("qpiMask(grid_data(:,:,%d), %d, 'gaussian_window', %.2f, '%s')", slice_idx, slice_idx, param2, param3), 0);
end

% Clean up variables
clearvars dataset variableIn variableOut1 variableOut2 variableOut3 inputData slice_idx param1 param2 param3

%% QP02A QPI-Process-02-A: Streak removal - Global streaks
% Created by Dong Chen in May 2025
%
% This section removes global streaks from QPI data by normalizing each scan line.
% The algorithm:
% - Calculates mean and variance for each row and column
% - Identifies lines with variance below threshold (using max variance as threshold)
% - Normalizes these lines to the global mean
% - Can be applied to horizontal, vertical, or both directions
%
% presets:
dataset = 'grid';           % specify the dataset to be used: e.g. grid
variableIn = 'dIdV_normalized';        % specify the input variable (dIdV data)
variableOut1 = 'dIdV_nostreaks'; % specify the variable name to store the streak-removed dIdV data
variableOut2 = 'QPI_nostreaks';  % specify the variable name to store the streak-removed QPI data
param1 = 'none';           % direction for streak removal: 'none' (both), 'horizontal', or 'vertical'

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOG data in/out:
LOGcomment = sprintf("Remove streaks from DataIn: %s.%s; and get dataOut: %s.%s and %s.%s", ...
    dataset, variableIn, dataset, variableOut1, dataset, variableOut2);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "QP02A", LOGcomment, 0);

% Get input data
inputData = data.(dataset).(variableIn);

% Remove streaks
[data.(dataset).(variableOut1), data.(dataset).(variableOut2)] = removeGlobalStreaks(inputData, ...
    'Direction', param1);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", sprintf("removeGlobalStreaks(dIdV, Direction='%s')", param1), 0);

figure; 
d3gridDisplay(data.grid.dIdV_nostreaks,'dynamic')

% Clean up variables
clearvars dataset variableIn variableOut1 variableOut2 inputData param1

%% QP02B QPI-Process-02-B: Streak removal - Local directional streaks
% Created by Dong Chen in May 2025
%
% This section removes local directional streaks from QPI data using Laplacian-based
% detection and neighbor interpolation. The process:
% 1. Identifies streaks in a reference slice using Laplacian magnitude
% 2. Applies the same streak removal to all slices at the detected indices
% 3. Uses neighbor interpolation to correct the streak regions
%
% presets:
dataset = 'grid';           % specify the dataset to be used: e.g. grid
variableIn = 'dIdV_nostreaks_local';        % specify the input variable (dIdV data)
variableOut = 'dIdV_nostreaks_local'; % specify the variable name to store the streak-removed data
param1 = [];               % optional: minimum value for streak detection
param2 = [];               % optional: Nx2 array of [row,col] indices for streak points
variableOut2 = 'streak_indices'; % specify the variable name to store the streak indices

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOG data in/out:
LOGcomment = sprintf("Remove local streaks from DataIn: %s.%s; and get dataOut: %s.%s and %s.%s", ...
    dataset, variableIn, dataset, variableOut, dataset, variableOut2);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "QP02B", LOGcomment, 0);

% Get input data
inputData = data.(dataset).(variableIn);

% Remove streaks
if isempty(param2)
    % Interactive mode: detect streaks and apply to all slices
    [data.(dataset).(variableOut), data.(dataset).(variableOut2)] = interpolateLocalStreaks(inputData, [], param1);
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", sprintf("interpolateLocalStreaks(QPI_data, [], %.2f)", param1), 0);
else
    % Non-interactive mode: apply provided streak indices to all slices
    [data.(dataset).(variableOut), data.(dataset).(variableOut2)] = interpolateLocalStreaks(inputData, [], param1, param2);
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", sprintf("interpolateLocalStreaks(QPI_data, [], %.2f, provided_indices)", param1), 0);
end

figure; 
d3gridDisplay(data.(dataset).(variableOut),'dynamic')

% Clean up variables
clearvars dataset variableIn variableOut variableOut2 inputData param1 param2

%% QP04A QPI-Process-04-A: Defect masking using Gaussian suppression
% Created by Dong Chen in May 2025
%
% This section masks defects in QPI data using Gaussian masking.
% The defect masking process:
% - Allows user to select defects in a chosen slice
% - Creates Gaussian masks for each defect
% - Applies the masks to suppress defect regions
% - Can handle multiple types of defects
%
% presets:
dataset = 'grid';           % specify the dataset to be used: e.g. grid
variableIn = 'dIdV_normalized';        % specify the input variable (real-space data)(make sure to use normalized data)
variableOut1 = 'dIdV_defectmasked'; % specify the variable name to store the masked real-space data
variableOut2 = 'QPI_defectmasked'; % specify the variable name to store the masked QPI data
variableOut3 = 'defect_centers'; % specify the variable name to store the defect centers
param1 = [];               % optional: specific slice to use for defect selection
param2 = 1;                % number of defect types to mask

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOG data in/out:
LOGcomment = sprintf("Mask defects in DataIn: %s.%s; and get dataOut: %s.%s, %s.%s, and %s.%s", ...
    dataset, variableIn, dataset, variableOut1, dataset, variableOut2, dataset, variableOut3);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "QP04A", LOGcomment, 0);

% Get input data
inputData = data.(dataset).(variableIn);

% Mask defects
[data.(dataset).(variableOut1), data.(dataset).(variableOut3), LOGcomment] = gaussianMaskDefects(inputData, param1, param2);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

% Calculate QPI of masked data
[data.(dataset).(variableOut2), LOGcomment] = qpiCalculate(data.(dataset).(variableOut1));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", "qpiCalculate(dIdV_masked)", 0);

% Clean up variables
clearvars dataset variableIn variableOut1 variableOut2 variableOut3 inputData param1 param2

%% QP05A QPI-Process-05-A: Square cropping
% Created by Dong Chen in May 2025
%
% This section crops the QPI data to a square shape.
%
% The cropping process:
% - Resizes the QPI data to a square shape
% - Centers the cropped data
%
% presets:
dataset = 'grid';           % specify the dataset to be used: e.g. grid
variableIn = 'QPI';         % specify the input variable (QPI data)
variableOut = 'QPI_cropped'; % specify the variable name to store the cropped QPI data

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOG data in/out:
LOGcomment = sprintf("Crop DataIn: %s.%s; and get dataOut: %s.%s", ...
    dataset, variableIn, dataset, variableOut);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "QP05A", LOGcomment, 0);

% Get input data
inputData = data.(dataset).(variableIn);

% Crop data
[data.(dataset).(variableOut), LOGcomment] = cropSquare(inputData);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

% Clean up variables
clearvars dataset variableIn variableOut inputData




