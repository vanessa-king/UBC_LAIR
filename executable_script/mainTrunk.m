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
    % LI01B Load-Initialize-01-B; Initializing the log file and UI select data
    % LG01A Load-Grid-01-A; load grid 
    % LG01B Load-Grid-01-B; load grid and topo from Nanonis
    % PA01A Processing-Averaging-01-A; applies moving-average smoothing to I-V
    % PC01A Processing-Correcting-01-A;
    % PC02A Processing-Correcting-02-A; correct the grid for drift 
    % VS01A Visualize-Spectrum-01-A; average I-V & dI/dV and plot them
    % VS02A Visualize-Spectrum-02-A; allows you to click on a grid/topo and plot the spectra
    % PD01A Porcessing-Derivative-01-A; create a regular dIdV for all I-V, and forward & backward separately.
    % PD01B Processing-Derivative-01-B; create a nomarlized dIdV (i.e. dIdV/I-V) for all I-V, and forward & backward separately.
    % VS01A Visualize-Spectrum-01-A; average I-V & dI/dV and plot them
    % VS01B Visualize-Spectrum-01-B; average normalized dI/dV and plot it;
    % VS02A Visualize-Spectrum-02-A;     
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

%set LOGfolder and LOGfile 
%*must not be changed during an iteration of data processing!
%*can be set automatically, e.g. when choosing
%only one topo file with uigetfile it automatically appends '_LOGfile' to the
%fiel name given.
LOGpath = folder;
LOGfile = strcat(stamp_project,"_grdNr_",grid_number,"_imgNr_",img_number,"_PpS_");
LOGcomment = "Initializing log file";
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LI01A", LOGcomment, 1);

%% LI01B Load-Initialize-01-B; Initialize log file, UI select data, load data

%   Edited by Markus, October 2023

% This section of code specifies the data paths, and files to be analyzed. 
% The log file is initialized based on the given file names and paths.
% Based on the file extension the appropriate load function is used. 

% work in progress!

%select data
[filePath, fileName, fileExt] = selectData();

%section on loading the files and getting file specific parameters 
%   not sure how to do this! 
%   might be read out of header when the file is loaded?

switch fileExt
    case '.flat'
        %Load flat file -> Matrix 
        %requires differentiating tyoe of data (IV grid, topo, ...)
    case '.3ds'
        %load 3ds file -> Nanonis grid
    case '.sxm'
        %load smx file -> Nanonis topo
    case '.dat'
        %load dat file -> Nanonis point spectrum
    case '.mat'
        %load .mat file -> Matlab workspace
        load(strcat(filePath,fileName,fileExt));
        %Note this option allows you to load a previously saved workspace.  
        %Only use it if you saved a workspace created by loading data via
        %this block before!
    otherwise
        disp("No file of appropriate data type selected")
end


% everything below covers logging the selected data

%select LOG file location
LOGpath = setLOGpath(filePath,1);
%set log file name
LOGfile = fileName; %Note logUsedBlocks() appends '_LOGfile.txt' 

%initialize LOG file & log name and directory
LOGcomment = "Initializing log file";
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LI01B", LOGcomment, 1);
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
%Edited by Vanessa summer 2023
% This section of code loads the files called above if they are Nanonis,

topoDirection='forward';
avg_forward_and_backward = true;
[grid,LOGcomment] = pythonDataToGrid(folder, stamp_project, grid_number, img_number, topoDirection);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "LG01B", LOGcomment ,0);

%% PA01A Processing-Averaging-01-A; applies moving-average smoothing to I-V
%Edited by James October 2023; Jisun October 2023

% This section of code applies moving-average smoothing to the I-V data of the grid. 

% span is the size of the moving window. For example, 3 is for nearest neighbor
% averaging; 5 is for next nearast neighbor averaging.
span = 3;
[grid.I, LOGcomment] = gridSmooth(grid.I,'grid.I',span);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PA01A", LOGcomment ,0);

if (~avg_forward_and_backward)
    [grid.I_Forward,LOGcomment] = gridSmooth(grid.I_Forward,'grid.I_Forward',span);
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0); 
    [grid.I_Backward,LOGcomment] = gridSmooth(grid.I_Backward,'grid.I_Backward',span);
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);
end
%% PD01A Porcessing-Derivative-01-A; create a regular dIdV for all I-V, and forward & backward separately. 
% Edited by: Jisun November 2023

% This section of code creates a regular dIdV data from the grid. It will create dIdV for all I-V; foward only; backward only. 
[didv, V_reduced, LOGcomment] = gridDerivative(grid);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PD01A", LOGcomment ,0);

if (~avg_forward_and_backward)
    gridForward = grid;
    [gridForward.I] = gridForward.I_Forward;
    [didv_forward, ~, LOGcomment] = gridDerivative(gridForward);
    LOGcomment = strcat("Forward_",LOGcomment);
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);
    
    gridBackward = grid;
    [gridBackward.I] = gridForward.I_Backward;
    [didv_backward, ~, LOGcomment] = gridDerivative(gridBackward);
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

%% PD01B Processing-Derivative-01-B; create a nomarlized dIdV (i.e. dIdV/I-V) for all I-V, and forward & backward separately. 
% When you run this section, your didv becomes/means normalized didv 
% and your grid.I becomes/means offset corrected I (see gridNormDerivative for details).
% Edited by: Jisun November 2023

% This section of code creates a normalized dIdV data from the grid. It will create dIdV for all I-V; foward only; backward only. 
C=3E-10;
[didv, I_correction, V_reduced, I_offset, LOGcomment] = gridNormDerivative(grid, C);
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PD02A", LOGcomment ,0);

if (~avg_forward_and_backward)
    gridForward = grid;
    [gridForward.I] = gridForward.I_Forward;
    [didv_forward, ~, ~, ~, LOGcomment] = gridNormDerivative(gridForward, C);
    LOGcomment = strcat("Forward_",LOGcomment);
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);
    
    gridBackward = grid;
    [gridBackward.I] = gridForward.I_Backward;
    [didv_backward, ~, ~, ~, LOGcomment] = gridNormDerivative(gridBackward, C);
    LOGcomment = strcat("Backward_",LOGcomment);
    LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);
end

%% VS01A Visualize-Spectrum-01-A; average I-V & dI/dV and plot them;
% Edited by Jisun Kim Oct 2023
% This section of code takes the average of the I-V and dI/dV. 
% Then it plots I versus V, dI/dV versus V for all I-V curves; forward and backward separately.
% NOTE: IF I DON'T RUN PD01A or PD01B, THIS SECTION DOESN'T RECOGNIZE V_reduced

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
LOGcomment = strcat(LOGcomment,sprintf(", plotname=%s",plot_name_1));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "VS01A", LOGcomment ,0);

% This makes the averaged "dI/dV versus V" plot
[avg_didv, f2, LOGcomment] = gridAvg(didv, V_reduced,1);
xlabel('V','fontsize', 20)
ylabel('dI/dV [a.u.]','fontsize', 20)
%xticks([-0.04 -0.02 0 0.02 0.04])
%xlim([-0.02 0.02])
%ylim([0 3e-9])
set(gca,'fontsize',20)

if f2 == []
else
    plot_name_2 = uniqueNamePrompt("average_dIdV","",LOGpath);
    savefig(f2, strcat(LOGpath,"/",plot_name_2,".fig"))
end
LOGcomment = strcat(LOGcomment,sprintf(", plotname=%s",plot_name_2));
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
    
    plot_name_3 = uniqueNamePrompt("forward_vs_backward_IV","",LOGpath);
    savefig(strcat(LOGpath,"/",plot_name_3,".fig"))
end
LOGcomment = strcat(LOGcomment,sprintf(", plotname=%s",plot_name_3));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

% This makes the averaged "dI/dV versus V" plot for forward and backward sweeps separately
[avg_didv_forward, f5, LOGcomment] = gridAvg(didv_forward, V_reduced);

if f5 == []
    clear f5
else
    %close f5;
end
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

[avg_didv_backward, f6, LOGcomment] = gridAvg(didv_backward, V_reduced,1);
if f6 == []
else
    hold on
    plot(V_reduced,avg_didv_forward)
    hold off
    legend('bwd', 'fwd');
    xlabel('V','fontsize', 20)
    ylabel('dI/dV [a.u.]','fontsize', 20);
    title("Avg dI/dV for bwd and fwd");
    
    plot_name_4 = uniqueNamePrompt("forward_vs_backward_dIdV","",LOGpath);
    savefig(strcat(LOGpath,"/",plot_name_4,".fig"))
end
LOGcomment = strcat(LOGcomment,sprintf(", plotname=%s",plot_name_4));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment ,0);

%create copy of the log corresponding to the saved figures
saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, strcat(plot_name_1, "+", plot_name_2, "+", plot_name_3,"+", plot_name_4));
clear plot_name_1 plot_name_2 plot_name_3 plot_name_4;



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
% Edited by Jisun Oct 2023
% This section of code creates a circular mask of radius R around a
% clicked point. It then plots the average dI/dV on that point. The user may toggle R and energy slice.

imageV = 0.0055;
radius = 3;
[circular_mask, Num_in_mask, LOGcomment] = gridMaskPoint(didv, V_reduced, imageV, radius);

plot_name_1 = uniqueNamePrompt("circular_mask_position","",LOGpath);
savefig(strcat(LOGpath,"/",plot_name_1,".fig"))
LOGcomment = strcat(LOGcomment,sprintf(", plotname=%s",plot_name_1));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "VS03A", LOGcomment ,0);

% Compute the average dI/dV spectra in the selected area
[~, mask_averaged_didv, LOGcomment] = gridAvgMask(didv, circular_mask);

% Generate the plot
figure; 
set(gca,'DefaultLineLineWidth',2)
set(gca,'FontSize',20)
plot(V_reduced, mask_averaged_didv,'b');  
ylabel('dI/dV [a.u.]','fontsize', 20)
xlabel('V','fontsize', 20)
xticks([-0.04 -0.02 0 0.02 0.04])
xlim([-0.05, 0.05])
ylim([0, 4E-9])

% Naming and saving the second figure
plot_name_2 = uniqueNamePrompt("mask_averaged_didv", "", LOGpath);
savefig(strcat(LOGpath, "/", plot_name_2, ".fig"));
LOGcomment = strcat(LOGcomment,sprintf(", plotname=%s",plot_name_2));
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "  ^  ", LOGcomment, 0);

% Create copy of the log corresponding to the saved figures
saveUsedBlocksLog(LOGpath, LOGfile, LOGpath, strcat(plot_name_1, "+", plot_name_2));
clear plot_name_1 plot_name_2;

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

%% PT01A Processing-Transforming-01-A; takes (Matrix) flat-style data and tranforms it to (Nanonis) array-style data
% Edited by James November 2023

[IV, dIdV, label, label_reduced, elayer, elayer_reduced, xsize, ysize, emax, emin, avg_dIdV, avg_IV] = matrixToNanonis(grid, 3E-10, 0);

LOGcomment = strcat("Transform to Nanonis style data");
LOGcomment = logUsedBlocks(LOGpath, LOGfile, "PT01A", LOGcomment ,0);
%% VS04A Visualize-Spectra-04-A: Plot All Spectra Faintly and Overlay the Average
% Edited by James November 2023

% Display grid dimensions to the user
disp(['Grid dimensions: xsize = ', num2str(xsize), ', ysize = ', num2str(ysize)]);

% Compute the average I/V and dI/dV values at each voltage point
for n = 1:elayer
    avg_IV(n) = mean(mean(IV(:,:,n)));  % Average I/V values
end

for k = 1:elayer - 1
    avg_dIdV(k) = mean(mean(dIdV(:,:,k)));  % Average dI/dV values
end

% Data Visualization: Raw and Average I/V
% Uncomment the block below to visualize individual I/V and dI/dV plots
%{
figure();
plot(label, reshape(avg_IV, elayer, 1));
ylim([1e-11, 10e-11]);
figure();
plot(label_reduced, reshape(avg_dIdV, elayer_reduced, 1));
ylim([1e-11, 10e-11]);
%}

% Clean up workspace to free memory and reduce clutter
clearvars -except elayer elayer_reduced label label_reduced avg_dIdV dIdV avg_IV IV emax emin xsize ysize

% Set parameters for plot aesthetics: transparency, line width, and colors
transp = 0.05;  % Transparency for individual spectra
lwidth1 = 1.5;  % Line width for individual spectra
lwidth2 = 2.5;  % Line width for average spectra
% Common color codes for reference
% Red [1, 0, 0], Green [0, 1, 0], Blue [0, 0, 1], Yellow [1, 1, 0], 
% Magenta [1, 0, 1], Cyan [0, 1, 1], Black [0, 0, 0], White [1, 1, 1], Gray [0.5, 0.5, 0.5]
pcolorb_raw = [0, 0, 1];  % color for raw data
pcolorb_avg = [0, 0, 0];  % color for average spectra

% User input for step size in I/V profile plotting
step_size_IV = input('Enter the step size for plotting I/V profiles: ');
if step_size_IV > xsize || step_size_IV > ysize || step_size_IV < 1
    error('Step size for I/V must be between 1 and the minimum of xsize or ysize.');
end

% Adjust loop limits based on actual array dimensions for I/V
max_i = min(xsize, size(IV, 1));
max_j = min(ysize, size(IV, 2));

% Plot I/V profiles with user-defined step size
figure();
for i = 1:step_size_IV:max_i
    for j = 1:step_size_IV:max_j
        plot1 = plot(label, reshape(IV(i, j, :), elayer, 1), 'color', pcolorb_raw, 'LineWidth', lwidth1);
        plot1.Color(4) = transp;  % Apply transparency to individual spectra
        hold on;
    end
end
plot(label, reshape(avg_IV, elayer, 1), 'color', pcolorb_avg, 'LineWidth', lwidth2);  % Overlay average I/V profile
ylim([-2.0e-10, 2e-10]);
title('Average I/V Profile', 'fontsize', 12);
xlabel('Bias Voltage [V]', 'fontsize', 12);
ylabel('I/V [a.u.]', 'fontsize', 12);
hold off;
axis square;

% User input for step size in dI/dV profile plotting
step_size_dIdV = input('Enter the step size for plotting dI/dV profiles: ');
if step_size_dIdV > xsize || step_size_dIdV > ysize || step_size_dIdV < 1
    error('Step size for dI/dV must be between 1 and the minimum of xsize or ysize.');
end

% Adjust loop limits based on actual array dimensions for dI/dV
max_i_dIdV = min(xsize, size(dIdV, 1));
max_j_dIdV = min(ysize, size(dIdV, 2));

% Plot dI/dV profiles with user-defined step size
figure();
for i = 1:step_size_dIdV:max_i_dIdV
    for j = 1:step_size_dIdV:max_j_dIdV
        plot1 = plot(label_reduced, reshape(dIdV(i, j, :), elayer_reduced, 1), 'color', pcolorb_raw, 'LineWidth', lwidth1);
        plot1.Color(4) = transp;  % Apply transparency to individual spectra
        hold on;
    end
end
plot(label_reduced, reshape(avg_dIdV, elayer_reduced, 1), 'color', pcolorb_avg, 'LineWidth', lwidth2);  % Overlay average dI/dV profile
ylim([0, 4e-9]);
title('Average dI/dV Profile', 'fontsize', 12);
xlabel('Bias Voltage [V]', 'fontsize', 12);
ylabel('dI/dV [a.u.]', 'fontsize', 12);
hold off;
axis square;