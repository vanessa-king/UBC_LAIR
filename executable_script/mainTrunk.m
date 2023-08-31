%% Test script for data processing with logging

%% Block logging
    %%   log file info
    
    % every block needs a unique identifier BLOCK (5 char long!) 
    % Format:   ABXXZ
    %      A:   L = loading, P = processing, V = visulalizing
    %      B:   subidentifiers (e.g. A = averaging, P = plot, M = masking, ...) TBD! 
    %     XX:   1, 2, 3, ..., 99 (running number for consecutive blocks)
    %      Z:   a, b, c, ... (alternate abc for either or blocks)

    % a full list of all 'codes' TBD, ideally name blocks as in this
    % example for future reference!

    % optionally a comment can be logged 
    % updating all functions to return a string of their name and
    % parameters used allows the comment to log the exact functions and
    % parameters used in every block.
%% Block List
    % LI01A Load-Initialize-01-A; Initializing the log file and choosing the data
    % LG01A Load-Grid-01-A; load grid 
    % LG01B Load-Grid-01-B; load grid and topo from Nanonis
    % PA01A Processing-Averaging-01-A; moving average
    % PC01A Processing-Correcting-01-A;
    % PC02A Processing-Correcting-02-A
    % VS01A Visualize-Spectrum-01-A; average I-V & dI/dV and plot them
    % VS02A Visualize-Spectrum-02-A;     
    % VS03A Visualize-Spectrum-03-A; circular masking
    % VT01A Visualize-Topo-01-A


%% LI01A Load-Initialize-01-A; Initializing the log file and choosing the data

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
%stamp_project = 'Grid_Spectroscopy--NbIrPtTe';

% set the grid I(V) file number
grid_number = '108_1';
% set the z-file (aka topo) image number
img_number = '54_1'; 
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
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LI01A", LOGcomment, 1);

%% LG01A Load-Grid-01-A; load grid 
% This section of code loads the files called above (grid_number and img_number),

avg_forward_and_backward = false;
[grid,LOGcomment] = gridLoadDataUpward_separate(folder,stamp_project,img_number,grid_number,avg_forward_and_backward); % Taking data Upward
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LG01A", LOGcomment ,0);

%% LG01B Load-Grid-01-B; load grid and topo from Nanonis
% This section of code loads the files called above if they are Nanonis,

topoDirection='forward';
avg_forward_and_backward = true;
[grid,LOGcomment] = pythonDataToGrid(folder, stamp_project, grid_number, img_number, topoDirection);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LG01B", LOGcomment ,0);

%% PA01A Processing-Averaging-01-A; moving average
% James is working on this, needs to save plot names in the log file
% This section of code first gets a time axis, to eventually plot against I(v) or di/dv.
% Second, it applies moving-average smoothing to the di/dv data vs time.

[time,LOGcomment] = getTimeAxis(pointsPerSweep, Traster);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PA01A", LOGcomment ,0);

[grid.I, LOGcomment] = gridSmooth(grid.I, time, 'grid.I', 'time'); % requires curve fitting toolbox
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

if (~avg_forward_and_backward)
    [grid.I_Forward,LOGcomment] = gridSmooth(grid.I_Forward,time,'grid.I_Forward', 'time');
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0); 
    [grid.I_Backward,LOGcomment] = gridSmooth(grid.I_Backward,time,'grid.I_Backward', 'time');
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);
   
end


%% PC01A Processing-Correcting-01-A;
% This section of code will do a vertical shift that brings the current at zero bias to zero.
C=3E-10;
smooth=false;
normalize=true;
[didv, norm_didv, I_correction, V_reduced, I_offset, LOGcomment] = gridCorrectionNorm(grid, C, smooth, normalize); 
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PC01A", LOGcomment ,0);
% why need the farward and backward 
if (~avg_forward_and_backward)
    gridForward = grid;
    [gridForward.I] = gridForward.I_Forward;
    [didv_forward, ~, ~, ~,  ~, LOGcomment] = gridCorrectionNorm(gridForward, 3E-10, smooth,normalize);
    LOGcomment = strcat("Forward_",LOGcomment);
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);
    
    gridBackward = grid;
    [gridBackward.I] = gridForward.I_Backward;
    [didv_backward, ~, ~, ~, ~, LOGcomment] = gridCorrectionNorm(gridBackward, 3E-10, smooth,normalize);
    LOGcomment = strcat("Backward_",LOGcomment);
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);
end    

%% PC02A Processing-Correcting-02-A;
% This section will correct the grid with the drifting parameter given. 

% need to know the function, talk to Jisun/Jiabin
% need to modify. 
%[grid,LOGcomment] = gridDriftCorr(grid, grid.z_img, grid.z_img, 5);
%LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PC02A", LOGcomment ,0);

%% VS01A Visualize-Spectrum-01-A; average I-V & dI/dV and plot them
% This section of code takes the average of the I(V) data (e.g., the whole
% grid) and plots both "I versus V" and "dI/dV versus V"
%
% NOTE: IF I DON'T RUN PC01A, THIS SECTION DOESN'T RECOGNIZE
% V_reduced

[number_bias_layer, ~] = size(V_reduced);

% This makes the averaged "I versus V" plot
[avg_iv, f1, LOGcomment] = gridAvg(grid.I, grid.V, 1);
xlabel('V','fontsize', 20)
ylabel('I(V) (nA)','fontsize', 20)

if f1 == []
else
    savefig(f1, strcat(LOGpath,"/average_IV.fig"))
end
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "VS01A", LOGcomment ,0);

% This makes the averaged "dI/dV versus V" plot
[avg_didv, f2, LOGcomment] = gridAvg(didv, V_reduced,1);
xlabel('V','fontsize', 20)
ylabel('dI/dV [a.u.]','fontsize', 20)
xticks([-0.04 -0.02 0 0.02 0.04])
xlim([-0.02 0.02])
ylim([0 3e-9])
set(gca,'fontsize',20)

if f2 == []
else
    savefig(f2, strcat(LOGpath,"/average_dIdV.fig"))
end
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

% This makes the averaged "I versus V" plot for forward and backward sweeps separately
[avg_iv_forward, f3, LOGcomment] = gridAvg(grid.I_Forward, grid.V);

if f3 == []
    clear f3
else
    %close f3;
end
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

[avg_iv_backward, f4, LOGcomment] = gridAvg(grid.I_Backward, grid.V,1);
if f4 == []
else
    hold on
    plot(grid.V,avg_iv_forward)
    hold off
    legend('bwd', 'fwd');
    xlabel('V','fontsize', 20)
    ylabel('I(V) (nA)','fontsize', 20);
    title("Avg I(V) for bwd and fwd");

    savefig(strcat(LOGpath,"/foreward_vs_backward_IV.fig"))
end
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

%create copy of the log corresponding to the saved figures
saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, "average_IV+average_dIdV+foreward_vs_backward_IV");

%% VS02A Visualize-Spectrum-02-A;
% This section of the code opens a GUI that allows you to click
% point(s) on a grid and plot the spectra
%
% NOTE: IF I DON'T RUN PC01A, THIS SECTION DOESN'T RECOGNIZE V_reduced

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
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "VS02A", LOGcomment ,0);

%save the created figures here:
savefig(strcat(LOGpath,"/",plotname,".fig"))

%create copy of the log corresponding to the saved figures
saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, plotname);
clear plotname;

%% VS03A Visualize-Spectrum-03-A; circular masking
% This section of code creates a circular mask of radius R around a
% clicked point. It then plots the average dI/dV on that point. The user may toggle R and energy slice.
%
% THIS SECTION IS CURRENTLY STRUCTURED FOR DONOR AND ACCEPTOR ENERGIES, SO
% WE WILL WANT TO MODIFY THIS ACCORDINGLY.


% plots di/dv at the specified energy (thrid input) and allows user to
% click on a point with a mask of radius R (fourth input)
imageV = 0.0055;
radius = 3;
[circular_mask, Num_in_mask, LOGcomment] = gridMaskPoint(didv, V_reduced, imageV, radius);

savefig(strcat(LOGpath,"/circular_mask_position.fig"))
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "VS03A", LOGcomment ,0);

%% VT01A Visualize-Topo-01-A;
% This section of code takes a slice of dI/dV at certain bias,defined by the user, and saves it.

% Ask the user to enter the bias of interest and plot name
bias_of_interest = input("Enter the bias of interest: ");
plot_name = input("Enter the plot name: ", 's');

% Convert the plot name to a cell array
plot_name_cell = {plot_name};

[Biases,LOGcomment] = gridPlotSlices(didv, V_reduced, bias_of_interest, plot_name_cell);

%savefig(strcat(LOGpath,"/grid_fullCaPt10-4-8_',stamp_project,'I(V)_32.fig"))
%WHAT SHOULD WE CALL THIS FIGURE?
filename = sprintf('%s/grid_fullCaPt10-4-8_%s_grid_%s.fig', LOGpath, stamp_project, grid_number);
savefig(filename);

LOGcomment = logUsedBlocks(LOGpath, LOGfile, "VT01A", LOGcomment ,0);

%create copy of the log corresponding to the saved figures
saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, "gridPlotSlices");

savefig(strcat(LOGpath,"/circular_mask_average_dIdV.fig"))
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

% takes the average of the dI/dV spectra in the selected area
[~, mask_averaged_didv, LOGcomment] = gridAvgMask(didv, circular_mask);

% plots the spectra at the spots where the masks were applied
figure; 
set(gca,'DefaultLineLineWidth',2)
set(gca,'FontSize',20)
plot(V_reduced, mask_averaged_didv,'b');  
ylabel('dI/dV [a.u.]','fontsize', 20)
xlabel('V','fontsize', 20)
xticks([-0.04 -0.02 0 0.02 0.04])
xlim([-0.05, 0.05])
ylim([0, 4E-9])

savefig(strcat(LOGpath,"/mask_averaged_didv.fig"))
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

%create copy of the log corresponding to the saved figures
saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, "circular_mask_position+mask_averaged_didv");
