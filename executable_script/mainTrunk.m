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
    % LG01A Load-Grid-01-A; load grid 
    % LG01B Load-Grid-01-B; load grid and topo from Nanonis
    % PA01A Processing-Averaging-01-A; generates time axis and applies moving-average smoothing to dI/dV
    % PC01A Processing-Correcting-01-A;
    % PC02A Processing-Correcting-02-A
    % VS01A Visualize-Spectrum-01-A; average I-V & dI/dV and plot them
    % VS02A Visualize-Spectrum-02-A;     
    % VS03A Visualize-Spectrum-03-A; circular masking
    % VT01A Visualize-Topo-01-A; visualizes a slice of dI/dV data at a user-defined bias and saves it


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
stamp_project = 'test'; 

% set the grid I(V) file number
grid_number = '002';
% set the z-file (aka topo) image number
img_number = '311'; 
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

%% LI01B Load-Initialize-01-B; Initializing the log file and choosing the data

% This section of code specifies the data paths, and files to be  
% analyzed. The log file is initialized based on the given values. 

% Markus work in progress!

%select data
[filePath, fileName, fileExt] = selectData();

%section on getting file specific parameters
%   not sure how to do this! 
%   might be read out of header when the file is loaded?



% everything below covers logging the selected data and 

%select LOG file location
LOGpath = setLOGpath(filePath,1);
%set log file name
LOGfile = fileName; %Note logUsedBlocks() appends '_LOGfile.txt' 

%initialize LOG file & log name and directory
LOGcomment = "Initializing log file";
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LI01A", LOGcomment, 1);
LOGcomment = strcat("LOGfile = ", LOGfile,"_LOGfile.txt");
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);
LOGcomment = strcat("LOGpath = ", LOGpath);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

%log selected data
LOGcomment = "Selected data file:";
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);
LOGcomment = strcat("filePath = ", filePath);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);
LOGcomment = strcat("fileName = ", fileName);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);
LOGcomment = strcat("fileExt = ", fileExt);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);


%% LG01A Load-Grid-01-A; load grid 
% This section of code loads the files called above (grid_number and img_number)

avg_forward_and_backward = false;
[grid,LOGcomment] = gridLoadDataUpward_separate(folder,stamp_project,img_number,grid_number,avg_forward_and_backward); % Taking data Upward
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LG01A", LOGcomment ,0);

%% LG01B Load-Grid-01-B; load grid and topo from Nanonis
% This section of code loads the files called above if they are Nanonis,

topoDirection='forward';
avg_forward_and_backward = true;
[grid,LOGcomment] = pythonDataToGrid(folder, stamp_project, grid_number, img_number, topoDirection);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LG01B", LOGcomment ,0);

%% PA01A Processing-Averaging-01-A; generates time axis and applies moving-average smoothing to dI/dV
%Edited by James October 2023

% This section carries out two primary tasks:
% 1. Computes a time axis to enable plotting against I(V) or dI/dV.
% 2. Applies moving-average smoothing to the dI/dV data with respect to time.

%1. Compute a time axis to enable plotting against I(V) or dI/dV.
[time,LOGcomment] = getTimeAxis(pointsPerSweep, Traster);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PA01A", LOGcomment ,0);

%2. Apply moving-average smoothing to the dI/dV data with respect to time.
[grid.I, LOGcomment] = gridSmooth(grid.I, time, 'grid.I', 'time');
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

if (~avg_forward_and_backward)
    [grid.I_Forward,LOGcomment] = gridSmooth(grid.I_Forward,time,'grid.I_Forward', 'time');
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0); 
    [grid.I_Backward,LOGcomment] = gridSmooth(grid.I_Backward,time,'grid.I_Backward', 'time');
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);
end
%% PC01A Processing-Correcting-01-A;choose to smooth or normalize the IV data. 
% Edited by: Dong October 2023 

% This section of code will do a vertical shift that brings the current at zero bias to zero, you could also smooth the IV.

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

%% VS01A Visualize-Spectrum-01-A; average I-V & dI/dV and plot them;
% Edited by Jisun Kim Oct 2023
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
    plot_name_1 = uniqueNamePrompt("average_IV","",LOGpath);
    savefig(f1, strcat(LOGpath,"/",plot_name_1,".fig"))
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
    plot_name_2 = uniqueNamePrompt("average_dIdV","",LOGpath);
    savefig(f2, strcat(LOGpath,"/",plot_name_2,".fig"))
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
    
    plot_name_3 = uniqueNamePrompt("foreward_vs_backward_IV","",LOGpath);
    savefig(strcat(LOGpath,"/",plot_name_3,".fig"))
end
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

%create copy of the log corresponding to the saved figures
saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, strcat(plot_name_1, "+", plot_name_2, "+", plot_name_3));
clear plot_name_1 plot_name_2 plot_name_3;

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

%% VS03A Visualize-Spectrum-03-A; circular masking; 
% Edited by Jisun Kim Oct 2023
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

plot_name = uniqueNamePrompt("circular_mask_position","a",LOGpath);
savefig(strcat(LOGpath,"/",plot_name,".fig"))
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "VS03A", LOGcomment ,0);
saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, plot_name);
clear plot_name;

%% VT01A Visualize-Topo-01-A; visualizes a slice of dI/dV data at a user-defined bias and saves it
%Edited by James October 2023

% This section of code takes a slice of dI/dV at certain bias, defined by the user, and saves it.

% This section visualizes a slice of dI/dV data at a user-defined bias and saves it. It also provides functionality to:
% 1. Prompt the user for the bias of interest and a name for the generated plot.
% 2. Convert the provided plot name to a cell array format for further processing.
% 3. Generate and save the slice plot, naming it based on the user input and other metadata.
% 4. Log the actions taken using the provided log blocks.
% 5. Compute the average of the dI/dV spectra within a designated area, specified by a circular mask.
% 6. Plot and save the averaged dI/dV spectra, and update the logs accordingly.

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