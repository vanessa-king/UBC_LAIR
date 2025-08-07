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
% QZ01A QPI-Zero-01-A: Zero background to dIdV data
% QP01A QPI-Process-01-A: Create and apply center-symmetric mask in q-space
% QP02A QPI-Process-02-A: Streak removal - Global streaks
% QP02B QPI-Process-02-B: Streak removal - Local directional streaks
% QP04A QPI-Process-04-A: Defect masking using Gaussian suppression

%% QZ01A QPI-Zero-01-A: Zero background to dIdV data
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
contrastMode = 'dynamic';   % range type: 'global' (all slices) or 'slice' (individual slices)
sliceIndices = '';          % optional: specific slice indices to normalize, if empty normalizes all slices
variableOut = 'dIdV_normalized'; % specify the variable name to store the normalized data

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOG data in/out:
LOGcomment = sprintf("Normalize DataIn: %s.%s; and get dataOut: %s.%s", ...
    dataset, variableIn, dataset, variableOut);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "QN01A", LOGcomment, 0);

% Get input data
inputData = data.(dataset).(variableIn);

% Normalize data
[data.(dataset).(variableOut), LOGcomment] = normalizeBackgroundToZeroMean3D(inputData, contrastMode, sliceIndices);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", sprintf("normalizeBackgroundToZeroMean3D(dIdV, '%s', %s)", contrastMode, mat2str(sliceIndices)), 0);

% Clean up variables
clearvars dataset variableIn variableOut inputData contrastMode sliceIndices

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
dataset = 'grid5';           % specify the dataset to be used: e.g. grid
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
variableIn = 'QPI';       % specify the input variable (dIdV or LockindIdV)   
contrastMode = 'dynamic';      % choose contrast range of each slice, 'global': [global min, global max] vs 'dynamic': [slice min, slice max].

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get input data
inputData = data.(dataset).(variableIn);

% display QPI
figure;
d3gridDisplay(inputData, contrastMode);

% Clean up variables
clearvars dataset variableIn contrastMode


%% QV02A QPI-Visualize-02-A: Make 2D slice from 3D QPI dataset
% Created by Dong Chen in May 2025
% 
% This section creates a 2D slice from 3D data by selecting two points.
% The process:
% - Creates either a line or line segment based on mode
% - Supports both dynamic and global contrast normalization
% - Returns both the slice data and the points used
% - Can use pre-defined points to skip interactive selection
%
% presets:
dataset = 'grid';           % specify the dataset to be used: e.g. grid
variableIn = 'QPI';         % specify the input variable (QPI data)
sliceType = 'segment';      % slice type: 'line' or 'segment'
contrastMode = 'global';    % contrast mode: 'dynamic' or 'global'
pointA = [133,230];                % pointA [y,x] coordinates (empty for interactive selection)
pointB = [381,284];                % pointB [y,x] coordinates (empty for interactive selection)
variableOut1 = 'QPI_slices';       % specify the variable name to store the slice data
variableOut2 = 'points';           % specify the variable name to store the points used

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOG data in/out:
LOGcomment = sprintf("Create 2D slice from DataIn: %s.%s; and get dataOut: %s.%s and %s.%s", ...
    dataset, variableIn, dataset, variableOut1, dataset, variableOut2);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "QV02A", LOGcomment, 0);

% Get input data
inputData = data.(dataset).(variableIn);

% Create slice with or without pre-defined points
[data.(dataset).(variableOut1), ~, LOGcomment, pointA, pointB] = d3sliceviewer(inputData, sliceType, contrastMode, pointA, pointB);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

% Store the points used
data.(dataset).(variableOut2) = struct('pointA', pointA, 'pointB', pointB);

% Add points to comment for reproducibility
LOGcomment = sprintf("%s | Points: A[%d,%d], B[%d,%d]", LOGcomment, pointA(1), pointA(2), pointB(1), pointB(2));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

% Clean up variables
clearvars dataset variableIn variableOut1 variableOut2 inputData sliceType contrastMode pointA pointB

%% picking and cropping within the bragg peaks
data.grid.QPI_mirrow_2=combined_data_xymirror(497:992,end-496+1:end,:);
data.grid.QPI_mirrow_1=combined_data_xymirror(1:496,end-496+1:end,:);
data.grid.QPI_fourfold_1=combined_data_fourfold(1:496,end-496+1:end,:);
data.grid.QPI_fourfold_2=combined_data_fourfold(497:992,end-496+1:end,:);
data.grid.QPI_fourfold_2=data.grid.QPI_fourfold_2(125:373,125:373,:);
data.grid.QPI_fourfold_1=data.grid.QPI_fourfold_1(125:373,125:373,:);
data.grid.QPI_mirrow_2=data.grid.QPI_mirrow_2(125:373,125:373,:);
data.grid.QPI_mirrow_1=data.grid.QPI_mirrow_1(125:373,125:373,:);
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
variableIn = 'QPI_fourfold_2';         % specify the input variable (QPI data)
variableOut1 = 'rotational_fourfold_2'; % specify the variable name to store the slice data
variableOut2 = 'slice_angles'; % specify the variable name to store the angles
contrastMode = 'global';    % range type: 'dynamic' (normalized per slice) or 'global' or 'log'
lineWidth = 1;              % line width in pixels
radius = size(data.(dataset).(variableIn),1)/2;                % radius of the ROI

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOG data in/out:
LOGcomment = sprintf("Create rotational slices from DataIn: %s.%s; and get dataOut: %s.%s and %s.%s", ...
    dataset, variableIn, dataset, variableOut1, dataset, variableOut2);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "QV03A", LOGcomment, 0);

% Get input data
inputData = abs(data.(dataset).(variableIn));

% Create rotational slices
[data.(dataset).(variableOut1), data.(dataset).(variableOut2), radius] = rotationalslices(inputData, contrastMode, lineWidth, radius);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", sprintf("rotational_slices(QPI, '%s', %d, radius = %d)", contrastMode, lineWidth, radius), 0);

% Clean up variables
clearvars dataset variableIn variableOut1 variableOut2 inputData contrastMode lineWidth

%% QP01A QPI-Processing-01-A: Create and apply center-symmetric mask in q-space
% Created by Dong Chen in May 2025

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
variableIn = 'dIdV_normalized';        % specify the input variable (real-space grid data)
sliceIdx = [];            % optional: specify slice index, if empty will show full 3D dataset
maskType = 'binary';      % mask mode: 'binary' or 'gaussian_window'
gaussianSigma = 2;        % sigma for gaussian window (only used if maskType is 'gaussian_window')
operationMode = 'select'; % operation mode: 'remove' or 'select'

variableOut1 = 'dIdV_masked'; % specify the variable name to store the masked real-space data
variableOut2 = 'QPI_masked'; % specify the variable name to store the masked QPI data
variableOut3 = 'QPI_mask';   % specify the variable name to store the mask

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOG data in/out:
LOGcomment = sprintf("Create QPI mask from DataIn: %s.%s; and get dataOut: %s.%s, %s.%s, and %s.%s", ...
    dataset, variableIn, dataset, variableOut1, dataset, variableOut2, dataset, variableOut3);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "QS01A", LOGcomment, 0);

% Get input data
inputData = data.(dataset).(variableIn);

% Create mask and apply it
if strcmp(maskType, 'binary')
    [data.(dataset).(variableOut3), data.(dataset).(variableOut1), data.(dataset).(variableOut2), LOGcomment] = qpiMask(inputData, sliceIdx, 'binary', [], operationMode);
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", sprintf("qpiMask(grid_data(:,:,%d), %d, 'binary', [], '%s')", sliceIdx, sliceIdx, operationMode), 0);
else
    [data.(dataset).(variableOut3), data.(dataset).(variableOut1), data.(dataset).(variableOut2), LOGcomment] = qpiMask(inputData, sliceIdx, 'gaussian_window', gaussianSigma, operationMode);
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", sprintf("qpiMask(grid_data(:,:,%d), %d, 'gaussian_window', %.2f, '%s')", sliceIdx, sliceIdx, gaussianSigma, operationMode), 0);
end

% Clean up variables
clearvars dataset variableIn variableOut1 variableOut2 variableOut3 inputData sliceIdx maskType gaussianSigma operationMode

%% QP02A QPI-Process-02-A: Full width streaks correction
% Created by Dong Chen in May 2025
%
% This section removes global streaks from QPI data by normalizing each scan line.
% The algorithm:
% - Calculates mean and variance for each row and column using non-masked regions
% - Normalizes these lines to the global mean
% - Can be applied to horizontal, vertical, or both directions
% - Optionally accepts a mask to specify regions to process
%
% presets:
dataset = 'grid5';           % specify the dataset to be used: e.g. grid
variableIn = 'dIdV_nostreaks';        % specify the input variable (dIdV data)
variableOut1 = 'dIdV_nostreaks'; % specify the variable name to store the streak-removed dIdV data
variableOut2 = 'QPI_nostreaks';  % specify the variable name to store the streak-removed QPI data
streakDirection = 'vertical';  % direction for streak removal: 'none' (both), 'horizontal', or 'vertical'
maskVariable = 'defect_mask';           % optional: variable name containing the mask to use (empty for no mask)

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOG data in/out:
LOGcomment = sprintf("Remove streaks from DataIn: %s.%s; and get dataOut: %s.%s and %s.%s", ...
    dataset, variableIn, dataset, variableOut1, dataset, variableOut2);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "QP02A", LOGcomment, 0);

% Get input data
inputData = data.(dataset).(variableIn);

% Get mask if specified
if ~isempty(maskVariable)
    mask = data.(dataset).(maskVariable);
    % Ensure mask is 2D
    if ndims(mask) > 2
        mask = mask(:,:,1);  % Use first slice if 3D
    end
    % Convert logical mask to numeric if needed
    if islogical(mask)
        mask = double(mask);  % Convert logical to double
    end
    % Remove streaks with mask
    [data.(dataset).(variableOut1), data.(dataset).(variableOut2)] = removeGlobalStreaks(inputData, mask, streakDirection);
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", ...
        sprintf("removeGlobalStreaks(dIdV, mask, '%s')", streakDirection), 0);
else
    % Remove streaks without mask
    [data.(dataset).(variableOut1), data.(dataset).(variableOut2)] = removeGlobalStreaks(inputData, [], streakDirection);
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", ...
        sprintf("removeGlobalStreaks(dIdV, [], '%s')", streakDirection), 0);
end

% Clean up variables
clearvars dataset variableIn variableOut1 variableOut2 inputData streakDirection maskVariable mask

%% QP02B QPI-Process-02-B: Partial width streaks correction 
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
variableIn = 'dIdV_nostreaks';        % specify the input variable (dIdV data)
variableOut1 = 'dIdV_nostreaks_local'; % specify the variable name to store the streak-removed data
variableOut2 = 'streak_mask';          % specify the variable name to store the streak mask
variableOut3 = 'streak_indices';       % specify the variable name to store the streak indices
referenceSlice = 150;       % slice index to use for streak detection
minStreakValue = [];        % optional: minimum value for streak detection
providedStreakIndices = []; % optional: Nx2 array of [row,col] indices for streak points

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOG data in/out:
LOGcomment = sprintf("Remove local streaks from DataIn: %s.%s; and get dataOut: %s.%s, %s.%s, and %s.%s", ...
    dataset, variableIn, dataset, variableOut1, dataset, variableOut2, dataset, variableOut3);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "QP02B", LOGcomment, 0);

% Get input data
inputData = data.(dataset).(variableIn);

% Remove streaks using the new 3D function
[data.(dataset).(variableOut1), data.(dataset).(variableOut2), data.(dataset).(variableOut3)] = ...
    interpolateLocalStreaks3D(inputData, referenceSlice, minStreakValue, providedStreakIndices);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", ...
    sprintf("interpolateLocalStreaks3D(QPI_data, %d, %.2f, %s)", referenceSlice, minStreakValue, ...
    mat2str(providedStreakIndices)), 0);

% Display results
figure; 
d3gridDisplay(data.(dataset).(variableOut1), 'dynamic');

% Clean up variables
clearvars dataset variableIn variableOut1 variableOut2 variableOut3 inputData referenceSlice minStreakValue providedStreakIndices

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
dataset = 'grid5';           % specify the dataset to be used: e.g. grid
variableIn = 'dIdV_nostreaks';        % specify the input variable (real-space data)(make sure to use normalized data)
variableOut1 = 'dIdV_defectmasked'; % specify the variable name to store the masked real-space data
variableOut2 = 'QPI_defectmasked'; % specify the variable name to store the masked QPI data
variableOut3 = 'defect_centers'; % specify the variable name to store the defect centers
variableOut4 = 'defect_mask';    % specify the variable name to store the defect mask
referenceSlice = [];        % optional: specific slice to use for defect selection
numDefectTypes = 1;         % number of defect types to mask

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOG data in/out:
LOGcomment = sprintf("Mask defects in DataIn: %s.%s; and get dataOut: %s.%s, %s.%s, %s.%s, and %s.%s", ...
    dataset, variableIn, dataset, variableOut1, dataset, variableOut2, dataset, variableOut3, dataset, variableOut4);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "QP04A", LOGcomment, 0);

% Get input data
inputData = data.(dataset).(variableIn);

% Mask defects
[data.(dataset).(variableOut1), data.(dataset).(variableOut3), data.(dataset).(variableOut4), LOGcomment] = gaussianMaskDefects(inputData, referenceSlice, numDefectTypes);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

% Calculate QPI of masked data
[data.(dataset).(variableOut2), LOGcomment] = qpiCalculate(data.(dataset).(variableOut1));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", "qpiCalculate(dIdV_masked)", 0);

% Clean up variables
clearvars dataset variableIn variableOut1 variableOut2 variableOut3 variableOut4 inputData referenceSlice numDefectTypes