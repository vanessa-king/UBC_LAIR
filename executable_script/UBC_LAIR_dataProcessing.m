%% Unified script for data processing

%% Block logging
    %%   log file info
    
    % every block needs a unique identifier BLOCK (ideally 5 char long) 
    % Format:   ABXXZ
    %      A:   L = loading, P = processing, V = visulalizing
    %      B:   subidentifiers (e.g. A = averaging, P = plot, M = masking, ...) TBD! 
    %     XX:   0, 1, 2, 3, ..., 99 (running number for consecutive blocks)
    %      Z:   a, b, c, ... (alternate abc for either or blocks)

    % optionally a comment can be logged 
    % updating all functions to return a string of their name and
    % parameters used allows the comment to log the exact functions and
    % parameters used in every block.


    %% INITA  here uigetfile is used to get file and path for a specific dataset
    [LOGfile,LOGpath] = uigetfile('*.*');
    %create log file; (__, 1) initialize log file 
    logUsedBlocks(LOGpath, LOGfile, "INITA", "testCommentInit", 1);
    %% UPD8A update log file
    logUsedBlocks(LOGpath, LOGfile, "UPD8A", "testCommentA" ,0);
    %% UPD8B update log file B
    logUsedBlocks(LOGpath, LOGfile, "UPD8B", logString ,0);
    %% SAVEA save copy with data
    logUsedBlocks(LOGpath, LOGfile, "SAVEA", "" ,0);
    saveUsedBlocksLog(LOGpath, LOGfile,LOGpath, "TestDataOutB")
    %%  Loading Data 


    %% Test 

    %% TestB

%% Processing & Visualizing Data
