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
% QC01A QPI-Compute-01-A; Compute QPI from dIdV/Lockin dIdV data


%% QC01A QPI-Compute-01-A; Compute QPI from dIdV/Lockin dIdV data
% Edited by Dong Chen in Apr 2025
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
variableIn = 'dIdV';       % specify the input variable (dIdV or LockindIdV)   
variableOut = 'QPI';       % specify the variable name to store the QPI data

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOG data in/out:
LOGcomment = sprintf("DataIn: %s.%s; dataOut: %s.%s", ...
    dataset, variableIn, dataset, variableOut);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "QC01A", LOGcomment, 0);

% Get input data
inputData = data.(dataset).(variableIn);

% Calculate QPI
[data.(dataset).(variableOut), LOGcomment] = qpiCalculate(inputData);

LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

% Clean up variables
clearvars dataset variableIn variableOut inputData

