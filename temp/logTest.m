%% Test script for data processing with logging

%% Block logging
    %%   log file info
    
    % every block needs a unique identifier BLOCK (5 char long!) 
    % Format:   ABXXZ
    %      A:   L = loading, P = processing, V = visulalizing
    %      B:   subidentifiers (e.g. A = averaging, P = plot, M = masking, ...) TBD! 
    %     XX:   0, 1, 2, 3, ..., 99 (running number for consecutive blocks)
    %      Z:   a, b, c, ... (alternate abc for either or blocks)

    % a full list of all 'codes' TBD, ideally name blocks as in this
    % example for future reference!

    % optionally a comment can be logged 
    % updating all functions to return a string of their name and
    % parameters used allows the comment to log the exact functions and
    % parameters used in every block.
%% Block List
    % LI00A Load-Initialize-00-A; Initializing the log file and choosing the data
    % LG00A Load-Grid-00-A; load grid 
    % LG00B Load-Grid-00-B; load grid and topo from Nanonis
    % PA01A Processing-Averaging-01-A; Moving average
    % PA01B Processing-Averaging-01-B;
    % VP01A Visualize-Plot-01-A;
    % VP01B Visualize-Plot-01-B; 
    


%% LI00A Load-Initialize-00-A; Initializing the log file and choosing the data

% (1) This section of code specifies the data paths, and files to be  
% analyzed. The log file is initialized based on the given values. 

% Potentially to be merged with (2) if grid load upwards is updated
% accordingly, to use uigetfile/uigetdir intrinsically. 

% use the pathApp (to be found on the LAIR Git) to add directories of your 
% data and scripts to the MATLAB path. 

% load all necessary script directories
folder = uigetdir('C:\Users\MarkusAdmin\OneDrive - UBC\MatlabProgramming\MATLAB_UBC\Test_Data');


% stamp_project is the filename leader and takes the form 'yyyymmdd-XXXXXX_CaPt--STM_Spectroscopy--';
stamp_project = 'TestData'; 
%stamp_project = 'Grid_Spectroscopy--NbIrPtTe';

% set the grid I(V) file number
grid_number = '007';
% set the z-file (aka topo) image number
img_number = '222'; 
% points/sweep used in the grid measurement
pointsPerSweep = 500;
% T-raster used in the grid measurement
Traster = 11.33 * 10^(-3); 

%set LOGfolder and LOGfile 
%*must not be changed during an iteration of data processing!
%*can be set automatically, e.g. when choosing
%only one topo file with uigetfile it automatically appends '_LOGfile' to the
%fiel name given.
LOGpath = folder;
LOGfile = strcat(stamp_project,"_grdNr_",grid_number,"_imgNr_",img_number,"_PpS_",num2str(pointsPerSweep),"_Traster_",num2str(Traster));
LOGcomment = "Initializing log file";
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LI00A", LOGcomment, 1);

%% LG00A Load-Grid-00-A; load grid 
% (2a) This section of code loads the files called above (grid_number and img_number),

avg_forward_and_backward = false;
[grid,LOGcomment] = gridLoadDataUpward_separate(folder,stamp_project,img_number,grid_number,avg_forward_and_backward); % Taking data Upward
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LG00A", LOGcomment ,0);

%% LG00B Load-Grid-00-B; load grid and topo from Nanonis
% (2b) This section of code loads the files called above if they are Nanonis,

topoDirection='forward';
avg_forward_and_backward = true;
[grid,LOGcomment] = pythonDataToGrid(folder, stamp_project, grid_number, img_number, topoDirection);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LG00B", LOGcomment ,0);

%% PA01A Processing-Averaging-01-A; Moving average
% (3a) This section of code first gets a time axis to plot against I(v) or di/dv.
% Second, it applies moving-average smoothing to the di/dv data vs time.

%in this section the comment is created maually instead of by altering the
%functions! This should not be the regular case! (I just don't want to
%change all functions now!)

time = getTimeAxis(pointsPerSweep, Traster);

grid.I = gridSmooth(grid.I,time); % requires curve fitting toolbox
LOGcomment = strcat(LOGcomment,"gridSmooth_Var=","grid.I","|","time","|"); %logging values is not useful here?
if (~avg_forward_and_backward)
    grid.I_Forward = gridSmooth(grid.I_Forward,time); 
    LOGcomment = strcat(LOGcomment,"gridSmooth_Var=","grid.I_Forward","|","time","|"); %logging values is not useful here? _Forward?  requires individual logging to see if statement was used or not...
    grid.I_Backward = gridSmooth(grid.I_Backward,time);
    LOGcomment = strcat(LOGcomment,"gridSmooth_Var=","grid.I_Backward","|","time","|"); %logging values is not useful here? _Backward?
end

LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PA01A", LOGcomment ,0);
%% PA01B Processing-Averaging-01-B;
% (3b) This section of code will does some funny vertical shifting. Dong will talk to
% Sarah about its purpose, as it's not clear that we need this.

[didv, norm_didv, I_correction, V_reduced] = gridCorrectionNorm(grid, 3E-10, 0,1); 
LOGcomment = strcat("gridCorrectionNorm_Var=","grid","|",num2str(3E-10),"|",num2str(0),"|",num2str(1),"|"); %note same as above, variables have to be adjustes maunally here! :(
if (~avg_forward_and_backward)
    gridForward = grid;
    [gridForward.I] = gridForward.I_Forward;
    [didv_forward, ~, ~, ~] = gridCorrectionNorm(gridForward, 3E-10, 0,1);
    LOGcomment = strcat(LOGcomment,"gridCorrectionNorm_Var=","gridForward","|",num2str(3E-10),"|",num2str(0),"|",num2str(1),"|");
    gridBackward = grid;
    [gridBackward.I] = gridForward.I_Backward;
    [didv_backward, ~, ~, ~] = gridCorrectionNorm(gridBackward, 3E-10, 0,1);
   LOGcomment = strcat(LOGcomment,"gridCorrectionNorm_Var=","gridBackward","|",num2str(3E-10),"|",num2str(0),"|",num2str(1),"|");
end    
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PA01B", LOGcomment ,0);
%% VP01A Visualize-Plot-01-A;
%(4) This section of code takes the average of the I(V) data (e.g., the whole
% grid) and plots both "I versus V" and "dI/dV versus V"
%
% NOTE: IF I DON'T RUN THE SECTION ABOVE, THIS SECTION DOESN'T RECOGNIZE
% V_reduced

[number_bias_layer, ~] = size(V_reduced);

% This makes the averaged "I versus V" plot
avg_iv = gridAvg(grid.I, grid.V, 1);
ylabel('I(V) (nA)')

savefig(strcat(LOGpath,"/average_IV.fig"))

LOGcomment = strcat("girdAvg_Var=","grid.I","|","grid.V","|",num2str(1),"|","plotAdjusted","|");

% This makes the averaged "dI/dV versus V" plot

avg_didv = gridAvg(didv, V_reduced,1);
ylabel('dI/dV [a.u.]','fontsize', 20)
xlabel('V','fontsize', 20)
xticks([-0.04 -0.02 0 0.02 0.04])
xlim([-0.02 0.02])
ylim([0 3e-9])
set(gca,'fontsize',20)

savefig(strcat(LOGpath,"/average_dIdV.fig"))

LOGcomment = strcat(LOGcomment,"gridAvg_Var=","didv","|","V_reduced","|",num2str(1),"|","plotAdjusted","|");


% This makes the averaged "I versus V" plot for forward and backward sweeps separately
avg_iv_forward = gridAvg(grid.I_Forward, grid.V);
gridAvg(grid.I_Backward, grid.V,1);
hold on
plot(grid.V,avg_iv_forward)
hold off
legend('bwd', 'fwd');
ylabel('I(V) (nA)');
title("Avg I(V) for bwd and fwd");

savefig(strcat(LOGpath,"/foreward_vs_backward_IV.fig"))

LOGcomment = strcat(LOGcomment,"gridAvg_Var=","grid.I_Forward","|","grid.V","|","girdAvg_Var=","grid.I_Backward","|","grid.V","|",num2str(1),"|","plotAdjusted","|");



LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PA01B", LOGcomment ,0);

%save the created figures here 

%create copy of the log corresponding to the saved figures
saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, "average_IV+average_dIdV+foreward_vs_backward_IV");


%% VP01B Visualize-Plot-01-B;
%(4.1) This section of the code opens a GUI that allows you to click
%point(s) on a grid and plot the spectra
%
% NOTE: IF I DON'T RUN PA01B, THIS SECTION DOESN'T RECOGNIZE V_reduced

imageV = 0.6; %float, Voltage at which to display image
n=1; %integer, Number of point spectra to plot
offset=0; %Vertical offset for each point spectra 
xysmooth=0.0; %float, the standard deviation of a Gaussian for smoothing xy pixels (0 is no smoothing)
vsmooth=0.0; %float, the standard deviation of a Gaussian for smoothing the voltage sweep points (0 is no smoothing)


LOGcomment = gridClickForSpectrum(didv, V_reduced, imageV, n, offset, xysmooth, vsmooth, grid);

%ask for plotname:
plotname = input("Save plot as: ","s");
if isempty(plotname)
    plotname = 'clickedSpectrum';
end

LOGcomment = strcat(LOGcomment,sprintf(", plotname=%s",plotname));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "VP01B", LOGcomment ,0);

%save the created figures here:
savefig(strcat(LOGpath,"/",plotname,".fig"))

%create copy of the log corresponding to the saved figures
saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, plotname);
clear plotname;
