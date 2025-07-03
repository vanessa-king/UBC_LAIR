%% SM01A Selecting-Mask-01-A; creates directional masks for data analysis
% Edited by Dong Chen in Dec 2024; Rysa June 2025
% Description:
% Generates directional masks for analyzing 2D or 3D datasets along a user-defined line,
% with adjustable perpendicular width selected either interactively or programmatically.
% These masks allow directional averaging, orientation-specific filtering, or local
% statistical analysis.
% By default, the function outputs:
%   data.grid.directional_masks — a 3D array of logical masks with size (X, Y, N),
%   where N is the number of narrow masks generated perpendicular to the main line.
% Optional parameters `bin_size` and `bin_sep` allow you to group (or "bin") these
% N narrow masks along the 3rd dimension into wider, combined masks for coarser analysis:
%   - bin_size:   The number of adjacent masks to combine into each bin.
%   - bin_sep:    The number of masks to move forward before starting the next bin.
%
% For example, setting bin_size = 2 and bin_sep = 3 results in bins that use every 3rd
% mask, each bin containing 2 consecutive masks:
%   Bin 1 → masks(:,:,1:2)
%   Bin 2 → masks(:,:,4:5)
%   Bin 3 → masks(:,:,7:8)
%
% This creates an additional output:
%   data.grid.directional_masks_combined — a 3D array with fewer, wider masks.
% Overlapping bins (bin_sep < bin_size) and gapped bins (bin_sep > bin_size) are allowed.

%presets:
dataset = 'topo';           % specify the dataset to be used: e.g. grid
variableIn1 = 'z';          % specify the variable to be processed 
n = 341;           % slice number (n-th index of 3rd dim of data) [optional]
variableOut = 'directional_masks';     % specify the variable name to store the masks
connected = false;         % flag for side connectivity in mask generation
saveplots = false;         % option to save plots (True: save; False: no save)

% Optional variable inputs
% set values to [] if not used
startPoint = [];           % [x,y] coordinates of start point, [] for interactive selection
endPoint = [];            % [x,y] coordinates of end point, [] for interactive selection
bin_size = [];             % number of masks to combine in each bin
bin_sep = [];              % separation between consecutive bins

%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LOG data in/out:
LOGcomment = sprintf("dataset = %s; variableIn1 = %s; n = %s; startPoint = %s; endPoint = %s; bin_size = %s; bin_sep = %s;" + ...
    " variableOut = %s; ", dataset, variableIn1, num2str(n), num2str(startPoint), num2str(endPoint), num2str(bin_size), num2str(bin_sep), ...
    variableOut);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "SM01A", LOGcomment, 0);

% Get input data
inputData = data.(dataset).(variableIn1);

% Create directional masks
[data.(dataset).(variableOut), data.(dataset).([variableOut '_combined']), LOGcomment] = ...
    maskDirectional(inputData, n, connected, startPoint, endPoint, bin_size, bin_sep);
if saveplots==true
    %ask for plotname:
    plot_name = uniqueNamePrompt("Directional mask","",LOGpath);
    LOGcomment = strcat(LOGcomment,sprintf(", plotname=%s",plot_name));
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);
    
    %save the created figures here:
    savefig(strcat(LOGpath,"/",plot_name,".fig"))
    %create copy of the log corresponding to the saved figures
    saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, plot_name);
else
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);
end
% Clean up variables
clearvars dataset variableIn1 n variableOut connected startPoint endPoint bin_size bin_sep inputData