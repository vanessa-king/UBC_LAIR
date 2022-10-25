%%
%(1) This section of code loads the necessary script directories, data paths,
% and files to be analyzed.

% load all necessary script directories
root_folder = 'C:\Users\jamesday\Documents\UBC\Data\CaPt\Tesla-Code';
addpath([root_folder '\custom_scripts']);
addpath([root_folder '\colourmaps'])
addpath([root_folder '\omicron'])

% add data path
addpath([root_folder '\CaPt_data']);
addpath([root_folder '\output'])

folder = '.';

% stamp_project is the filename leader and takes the form 'yyyymmdd-XXXXXX_CaPt--STM_Spectroscopy--';
stamp_project = '20210801-161607_CaPt--STM_Spectroscopy--'; 

% set the grid I(V) file number
grid_number = '17_1';
% set the z-file (aka topo) image number
img_number = '153_1'; 
% points/sweep used in the grid measurement
pointsPerSweep = 500;
% T-raster used in the grid measurement
Traster = 11.33 * 10^(-3); 

%%
%(2) This section of code loads the files called above (grid_number and img_number),
% in either the upward or downward direction, to create "grid". Only one of upward or downward should be used.

%Take the upward data
avg_forward_and_backward = false;
grid = gridLoadDataUpward(folder,stamp_project,img_number,grid_number, avg_forward_and_backward);

%Take the downward data
% grid = gridLoadDataDownward(folder,stamp_project,img_number,grid_number); % Taking data Downward

%%
%(3) This section of code (first) creates a time axis to plot against I(V)
% or dI/dV and then (second) it applies moving-average smoothing to the dI/dV data vs time.

time = getTimeAxis(pointsPerSweep, Traster);
grid.I = gridSmooth(grid.I,time); % requires curve fitting toolbox
if (~avg_forward_and_backward)
    grid.I_Forward = gridSmooth(grid.I_Forward,time); 
    grid.I_Backward = gridSmooth(grid.I_Backward,time);
end
%%
%(4) This function generates a normalized and smoothed (optional) dI/dV data set.
% This section generates grid and MUST be run. 
% Also, I need to change GridCorrNorm to GridCorrectionNorm

[didv, norm_didv, I_correction, V_reduced] = gridCorrNorm(grid, 3E-10, 0); 
if (~avg_forward_and_backward)
    gridForward = grid;
    [gridForward.I] = gridForward.I_Forward;
    [didv_forward, ~, ~, ~] = gridCorrNorm(gridForward, 3E-10, 0);
    gridBackward = grid;
    [gridBackward.I] = gridForward.I_Backward;
    [didv_backward, ~, ~, ~] = gridCorrNorm(gridBackward, 3E-10, 0);
end    

%%
%(5) This takes (Matrix) flat-style data and converts it to (Nanonis) array-style data
[IV, dIdV, label, label_reduced, elayer, elayer_reduced, xsize, ysize, emax, emin, avg_dIdV, avg_IV] = matrixToNanonis(grid, 3E-10, 0);

%%
%(6) This pulls out the y-axis variables IV and dI/dV, for each point along the
% bias sweep and creates I/V average and dI/dV average.

for n=1:elayer;
   avg_IV(n) = mean(mean(IV(:,:,n)));
end

for k=1:elayer-1;
    avg_dIdV(k) = mean(mean(dIdV(:,:,k))); % all lines and all columns for eack bias point along the sweep 
end

%% 
%(6b) plot I/V and dI/dV alone
%figure()
%plot(label,reshape(avg_IV(:),elayer,1))
%ylim([1e-11 10e-11])

%figure()
%plot(label_reduced,reshape(avg_dIdV(:),elayer_reduced,1))
%ylim([1e-11 10e-11])

%%
% (7) Clear variables
clearvars -except elayer elayer_reduced label label_reduced avg_dIdV dIdV avg_IV IV emax emin xsize ysize

%%
%(7) Set basic plotting parameters
transp =0.01;
lwidth1=1.5;
lwidth2=2.5;
pcolorb_avg=[1,0,0]; %RGB color scheme
pcolorb_raw=[0,0,0]; %RGB color scheme

%%
%(8) Plot I/V, raw and average
figure()
for i=1:32 %The range for each i and j can't exceed xsize and ysize
for j=1:32
    plot1=plot(label,reshape(IV(i,j,:),elayer,1),'color',pcolorb_avg,'LineWidth',lwidth1);
    plot1.Color(4)=transp; % a color specification which is in the form of a four element vector of doubles in the range 0 to 1. The elements are in the order R G B A. So Color(1) would be the red component, (2) would be the green component, (3) would be the blue component, and (4) is the alpha component.
    hold on
end
end
plot(label,reshape(avg_IV(:),elayer,1),'color',pcolorb_raw,'LineWidth',lwidth2) %this plots the average of all the above lines, and should be equivalent to Figure 1 generated in Open_3ds.m

ylim([-2.0e-10 2e-10])

title('average I/V','fontsize',12)
xlabel('bias voltage [V]','fontsize',12)
ylabel('I/V [a.u.]','fontsize',12)
%set(gca,'fontsize',24)
hold off
axis square

%%
%(9)Plot dI/dV, raw and average
figure()
for i=1:32 %The range for each i and j can't exceed xsize and ysize
for j=1:32
    plot1=plot(label_reduced,reshape(dIdV(i,j,:),elayer_reduced,1),'color',pcolorb_avg,'LineWidth',lwidth1);
    plot1.Color(4)=transp; % a color specification which is in the form of a four element vector of doubles in the range 0 to 1. The elements are in the order R G B A. So Color(1) would be the red component, (2) would be the green component, (3) would be the blue component, and (4) is the alpha component.
    hold on
end
end
plot(label_reduced,reshape(avg_dIdV(:),elayer_reduced,1),'color',pcolorb_raw,'LineWidth',lwidth2) %this plots the average of all the above lines, and should be equivalent to Figure 1 generated in Open_3ds.m

ylim([0 4e-9])

title('average dI/dV','fontsize',12)
xlabel('bias voltage [V]','fontsize',12)
ylabel('dI/dV [a.u.]','fontsize',12)
%set(gca,'fontsize',24)
hold off
axis square

