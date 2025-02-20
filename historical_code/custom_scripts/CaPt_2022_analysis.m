%%
% (1) This section of code loads the necessary script directories, data paths,
% and files to be analyzed.

% load all necessary script directories
root_folder = 'C:\Users\MarkusAdmin\OneDrive - UBC\MatlabProgramming\MATLAB_UBC\UBC_LAIR';


folder = '.';

% stamp_project is the filename leader and takes the form 'yyyymmdd-XXXXXX_CaPt--STM_Spectroscopy--';
stamp_project = '20210308-124244_CaPt--STM_Spectroscopy--'; 

% set the grid I(V) file number
grid_number = '108_1';
% set the z-file (aka topo) image number
img_number = '54_1'; 
% points/sweep used in the grid measurement
pointsPerSweep = 500;
% T-raster used in the grid measurement
Traster = 11.33 * 10^(-3); 

%%
% (2) This section of code loads the files called above (gird_number and img_number),
% in either the upward or downward direction, to create "grid". Only one of upward or downward should be used.

avg_forward_and_backward = false;
grid = gridLoadDataUpward(folder,stamp_project,img_number,grid_number, avg_forward_and_backward); % Taking data Upward
% grid = gridLoadDataDownward(folder,stamp_project,img_number,grid_number); % Taking data Downward

%% Moving average
% (3a) This section of code first gets a time axis to plot against I(v) or di/dv.
% Second, it applies moving-average smoothing to the di/dv data vs time.

time = getTimeAxis(pointsPerSweep, Traster);
grid.I = gridSmooth(grid.I,time); % requires curve fitting toolbox
if (~avg_forward_and_backward)
    grid.I_Forward = gridSmooth(grid.I_Forward,time); 
    grid.I_Backward = gridSmooth(grid.I_Backward,time);
end
%% 
% (3b) This section of code will does some funny vertical shifting. Dong will talk to
% Sarah about its purpose, as it's not clear that we need this.

[didv, norm_didv, I_correction, V_reduced] = gridCorrectionNorm(grid, 3E-10, 0,1); 
if (~avg_forward_and_backward)
    gridForward = grid;
    [gridForward.I] = gridForward.I_Forward;
    [didv_forward, ~, ~, ~] = gridCorrectionNorm(gridForward, 3E-10, 0,1);
    gridBackward = grid;
    [gridBackward.I] = gridForward.I_Backward;
    [didv_backward, ~, ~, ~] = gridCorrectionNorm(gridBackward, 3E-10, 0,1);
end    

%% 
%(4) This section of code takes the average of the I(V) data (e.g., the whole
% grid) and plots both "I versus V" and "dI/dV versus V"
%
% NOTE: IF I DON'T RUN THE SECTION ABOVE, THIS SECTION DOESN'T RECOGNIZE
% V_reduced

[number_bias_layer, ~] = size(V_reduced);

% This makes the averaged "I versus V" plot
avg_iv = gridAvg(grid.I, grid.V,1);
ylabel('I(V) (nA)')

% This makes the averaged "dI/dV versus V" plot
avg_didv = gridAvg(didv, V_reduced,1);
ylabel('dI/dV [a.u.]','fontsize', 20)
xlabel('V','fontsize', 20)
xticks([-0.04 -0.02 0 0.02 0.04])
%xlim([-0.02 0.02])
ylim([0 3e-9])
set(gca,'fontsize',20)

% This makes the averaged "I versus V" plot for forward and backward sweeps separately
avg_iv_forward = gridAvg(grid.I_Forward, grid.V);
gridAvg(grid.I_Backward, grid.V,1);
hold on
plot(grid.V,avg_iv_forward)
hold off
legend('bwd', 'fwd');
ylabel('I(V) (nA)');
title("Avg I(V) for bwd and fwd");

% This makes the averaged "dI/dV versus V" plot for forward and backward sweeps separately
avg_didv_forward = gridAvg(didv_forward, V_reduced);
gridAvg(didv_backward, V_reduced,1);
hold on
plot(V_reduced,reshape(avg_didv_forward(:),number_bias_layer,1))
hold off
legend('bwd', 'fwd');
ylabel('dI/dV [a.u.]')
xlabel('V','fontsize', 14)
xticks([-0.04 -0.02 0 0.02 0.04])
ylim([0 4.5e-9])

%%
% (5) This section of code plots the few selected dI/dV, depending on where
% the user clicked, and saves them. The main toggle here is the fourth input which defines
% the number of point spectra to plot. Since gridClickForSpectrum plots
% 'Topology associated with grid' with reduced resolution to match grid's
% pixel size, you can choose to plot the topography image with the full
% resolution by putting 1 after 200 in topoPlaneSub(grid,200,1) inside gridClickForSpectrum. 
% See topoPlaneSub function for details.
% Currently it's set to plot 'Plane Subtracted Topography'.

gridClickForSpectrum(didv, V_reduced, 0, 3, 0, 0,0,grid) % requires Image Processing Toolbox

set(gca,'FontSize',20,'XLim',[-0.05,0.05],'YLim',[-0.1E-8,0.8E-8])
ylabel('dI/dV [a.u.]','fontsize', 14)
xlabel('V','fontsize', 14)
xticks([-0.04 -0.02 0 0.02 0.04]);
saveas(gca,[root_folder, '\output', '/grid',grid_number,'I(V)-A.png']) %make sure to update the saved filename
%%
% (6) This section of code takes a slice of dI/dV at certain bias,defined by the user, and saves it.

gridPlotSlices(didv,V_reduced, [0.0045, 0.007, 0.009],["TestplotA","TestplotB","TestplotC"]); %be sure to set the bias you want (third input) and make certain that this title name is set appropriately ["name"]

%saveas(gca,[root_folder, '\output','/grid_fullCaPt10-4-8_',stamp_project,'I(V)_32.png']) %make sure to update the saved filename
%%
% (7) This section of code makes a movie of all energy slices from grid
% measurement and saves it.

v = VideoWriter([root_folder, '\output', '/grid_CaPt10-4-8_movie_',stamp_project,'I(V)_',num2str(grid_number),'.avi']);
gridMovie(didv, V_reduced, v); 

%% Grid thresholding
% (8) This section of code thresholds a grid of dI/dV data at a specific
% bias either through the median or a custom value of dI/dV amplitude. This sectioning is shown as a boundary on
% dI/dV image at a specific bias the user chose, as well as separate "bright" and "dark" spectra.

% Enter the bias value to plot dI/dV image at this bias
bias = 0.0047;
%1 indicates using median threshold value in gridGetThreshold, 0 to have an option to choose a custom value
grid_thresh = gridGetIVThreshold(didv, V_reduced, bias, 5);
avg_didv_bright = gridAvgFilter(didv, V_reduced, grid_thresh.bright_indices);
avg_didv_dark = gridAvgFilter(didv, V_reduced, grid_thresh.dark_indices);

% This makes the "bright" and "dark" spectra plots. Bright means the
% spectra above the threshold are averaged together. Dark means the spectra
% below or equal to the threshold are averaged together. 
figure();
plot(V_reduced,avg_didv_bright)
hold on
plot(V_reduced, avg_didv_dark)
%title("Average dI/dV for bright and dark");
ylabel('dI/dV [a.u.]','fontsize', 14)
xlabel('V','fontsize', 14)
xticks([-0.04 -0.02 0 0.02 0.04])
ylim([0 3e-9])
set(gca,'fontsize',20)
legend("Bright", "Dark",'fontsize', 14);
%axis square
hold off

%% grid threshold plot on topology
% (9) This section of code plots a plane substracted topographic image. Then, it
% overlays a boundary determined in the section (8) over the topographic image.

didv_flip = flip(permute(didv,[1 3 2]),2); % flip didv so that image (x,y) = (0,0) at the bottom left
topo = topoPlaneSub(grid,200,0); % subtract plane
fig_name = 'Topology associated with grid';
z_img = flip(permute(topo,[2 1]),1);
fig_plot = imresize(z_img, [size(didv_flip,2), size(didv_flip,3)]);
img = figure('Name', fig_name); imagesc(fig_plot); colormap('gray'); hold on
axis image
hold on;
plot(grid_thresh.boundary_x, grid_thresh.boundary_y, 'g', 'LineWidth', 2);
hold off
%% topo thresholding
% (10) This section of code is similar to the section (8) but for thresholding, it uses topographic height
% distribution instead of dI/dV amplitude. 
%
% 1 indicates using median threshold value in topoGetThreshold, 0 to have an option to choose a custom value
topo_thresh = topoGetThreshold(topo);
avg_iv_tall = gridAvgFilter(didv, V_reduced, topo_thresh.tall_indices);
avg_iv_short = gridAvgFilter(didv, V_reduced, topo_thresh.short_indices);

figure();
plot(V_reduced,avg_iv_tall)
hold on
plot(V_reduced, avg_iv_short)
title("Average dI/dV for tall and short");
xlabel("V")
ylabel("Avg iv data")
legend("Tall", "Short");
axis square
hold off
%% Topo threshold plot on grid
% (11) This section of code plots a dI/dV image chosen at the section (8). Then, it
% overlays a boundary determined in the section (10) over the dI/dV image.
[~,imN] = min(abs(V_reduced-bias));
didv_slice = squeeze(didv_flip(imN, :, :));
figure();
clims = [1.7E-9,3E-9];
imagesc(didv_slice, clims);
axis square
title(['Slice at ',num2str(bias),' V']);
color_scale_resolution = 1000; % 1000 evenly spaced colour points
cm_viridis = viridis(color_scale_resolution); % Default matplotlib(for LAIR)
colormap(cm_viridis)
colorbar
hold on
plot(topo_thresh.boundary_x,topo_thresh.boundary_y, 'g', 'LineWidth', 2);
hold off

%%
% (12) This section of code creates a circular mask of radius R around a
% clicked point. It then plots the average dI/dV on that point. The user may toggle R and energy slice.
%
% THIS SECTION IS CURRENTLY STRUCTURED FOR DONOR AND ACCEPTOR ENERGIES, SO
% WE WILL WANT TO MODIFY THIS ACCORDINGLY.

% plots di/dv at the specified energy (thrid input) and allows user to
% click on a point with a mask of radius R (fourth input)
A_mask = gridMaskPoint(didv, V_reduced, 0.0055, 2);
%D_mask = gridMaskPoint(didv, Vred, -0.0019, 2);

% takes the average of the dI/dV spectra in the selected area
[~, A_sts] = gridAvgMask(didv, A_mask);
%[~, D_sts] = gridAvgMask(didv, D_mask);

% plots the spectra at the spots where the masks were applied
figure; hold on;
set(gca,'DefaultLineLineWidth',2)
set(gca,'FontSize',20)
%plot(Vred, D_sts); 
plot(V_reduced, A_sts,'b');  
ylabel('dI/dV [a.u.]','fontsize', 20)
xlabel('V','fontsize', 20)
xticks([-0.04 -0.02 0 0.02 0.04])
xlim([-0.05, 0.05])
ylim([0, 4E-9])
%legend('Donor','Acceptor','Au')
%legend('negative','positive')
xlabel('Bias (V)')
ylabel('dI/dV a.u.)')
hold off

%%
% (13) This section of code should run like the previous one, but here you
% click two points that define a single rectangle (presumably, opposite
% corners).

% plots dI/dV at the specified energy (thrid input) and allows user to
% click on two points to define a rectangle.
B_mask = gridMaskSquare(didv, V_reduced, 0.0019);

% takes the average of the dI/dV spectra in the selected area
[~, B_sts] = gridAvgMask(didv, B_mask);

% plots the spectra at the spots where the masks were applied
figure; hold on;
set(gca,'DefaultLineLineWidth',2)
set(gca,'FontSize',20)
plot(V_reduced, B_sts); 
xlim([-0.05, 0.05])
%legend('Donor','Acceptor','Au')
legend('average didv on square')
xlabel('Bias (V)')
ylabel('dI/dV')
hold off

%%
%(TBD) We have never used this one yet. The codes from this section are to plot QPI dipersion.
% Note: it is in this section and below that some errors (see orange bars to the side) start popping up.
for k=1:200 % picking 200 energy evenly, from IV direclty, 200 didv 0 is missing.
    didv2(:,:,k) = didv(k,:,:); %arrange as (x,y,k)
    Med(k) = median(median(didv2(:,:,k))); %median twice, pick one specific peak in histogram
    sg(k) = std(std(didv2(:,:,k))); %  Standard deviation twice with the peak
end

%% For real space grid map

% eint=1;
% for k=1:200/eint
% %     energy = -202+2*k;
for k=1:50
    const=50; % constant number for caxis contrast.
    energy = -202+2*k;
    figure(13)
    t = sprintf(  'k = %d, Energy: %d mV',k,energy);
    figure(13)
    imagesc(rot90(didv2(:,:,k))) %plot 2D image
    
    hold on
    pbaspect([1 1 1]) %image size ratio [x,y,1]
    set(gcf, 'Colormap', gray)
    xticks([])
    yticks([])
     title(t)
   caxis([min(min(didv2(:,:,k))) 2*max(max(didv2(:,:,k)))])
    caxis([Med(k)-const*sg(k) Med(k)+const*sg(k)])
    
    
    name = sprintf('./realimagedata/k_%d.jpg',k);    %name of the figure
    saveas(13,name)  %save figure 13 as name
% eval([fname = [''dIdV'',num2str(k,''%03u''),''_(r,E='', num2str(-200+(k-1)*2) mV).png''];'])      
   % F = getframe(gca);
 %   imwrite(F.cdata,['output2/grid_NbIrTe4_Tmovie_',stamp_project,'dI(V)_',num2str(iv_nbr),'.png']])
end
%%


%% From real space igame to QPI
%qcenter=101;  % to define a center first 
qcenter = 29;
for k=1:200
    qpi(:,:,k)=abs(fftshift(fft2(didv2(:,:,k))));
    qpi(qcenter, qcenter, k)=0; % define the center has lowest intensity
end
for k=1:200
    QPI(:,:,k) = (qpi(:,:,k) + fliplr(qpi(:,:,k)))/2; % increase signal/noise level, left-right mirror symmetry
   % QPI(:,:,k) = (qpi2(:,:,k) +flipud(qpi2(:,:,k)))/2;
end
for k=1:200
    Medq(k) = median(median(QPI(:,:,k))); % same as real space, pick one specific peak in histogram
    sgq(k) = std(std(QPI(:,:,k)));
end
%% plot qpi 
constq=2;
eint=5;
for k=1:200/eint
    energy = -210+10*k;
    t = sprintf(  'k = %d, Energy: %d mV',k,energy);
    figure(11)
%     imagesc(rot90(QPI(:,:,k*eint))) % the original one
      imagesc(rot90(QPI(:,:,k*eint)))
    hold on
    pbaspect([1 1 1])
    set(gcf, 'Colormap', gray)
    xticks([])
    yticks([])
    title(t)
   caxis([Medq(k*eint)-constq*sgq(k*eint) Medq(k*eint)+constq*sgq(k*eint)])
   
   
   
   name = sprintf('./qpidata/k_%d.jpg',k);    %name of the figure
%    title('energy is ','./qpidata/k');
   saveas(11,name)  %save figure 11 as name
end

% %
% vqpi = VideoWriter(['output/grid_NbIrTe4_Tmovie_',stamp_project,'QPI_',num2str(iv_nbr),'.avi']);
% gridMovie(rot90(QPI), Vred, vqpi); 



%% plot slide cut of QPI

%%
%for k=1:200 % picking 200 energy evenly, from IV direclty, 200 norm_didv 0 is missing.
%  QPI2 = smoothdata(QPI,'gaussian',2);    
% lineqy(:,:) = QPI(97,:,:)+2*QPI(98,:,:)+3*QPI(99,:,:)+5*QPI(100,:,:)+5*QPI(101,:,:)+3*QPI(102,:,:)+2*QPI(103,:,:)+QPI(104,:,:); %arrange as (qx,k,qy)
lineqy(:,:) = QPI(qcenter - 4,:,:)+2*QPI(qcenter - 3,:,:)+3*QPI(qcenter - 2,:,:)+5*QPI(qcenter - 1,:,:)+5*QPI(qcenter,:,:)+3*QPI(qcenter + 1,:,:)+2*QPI(qcenter + 2,:,:)+QPI(qcenter + 3,:,:); %arrange as (qx,k,qy)
% lineqy(:,:) = QPI(101,:,:); %arrange as (qx,k,qy)
%lineqx(:,:) = QPI(:,101,:); %arrange as (qx,k,qy)
lineqx(:,:) = QPI(:,qcenter,:); %arrange as (qx,k,qy)
      %  lineqy(:,:) = QPI(110,:,:); %arrange as (qx,k,qy)

   % Med(k) = median(median(lineqy(:,:,k))); %median twice, pick one specific peak in histogram
  %  sg(k) = std(std(lineqy(:,:))); %  Standard deviation twice with the peak
%end

%% For real space grid map
%for k=110:110
%     const=0.1; % constant number for caxis contrast.
    figure(14)
%     imagesc(flipud(rot90(lineqy(:,:)))) %plot 2D image
     imagesc(rot90(lineqy(:,:))) %plot 2D image
%     imagesc(rot90(lineqx(:,:))) %plot 2D image

    hold on
    set(gcf, 'Colormap', gray)
    xticks([])
    yticks([])
  %  caxis([min(min(norm_didv2(:,:,k))) 2*max(max(norm_didv2(:,:,k)))])
%    caxis([Med(k)-const*sg(k) Med(k)+const*sg(k)])

% eval([fname = [''Norm_dIdV'',num2str(k,''%03u''),''_(r,E='', num2str(-200+(k-1)*2) mV).png''];'])      
   % F = getframe(gca);
 %   imwrite(F.cdata,['output2/grid_NbIrTe4_Tmovie_',stamp_project,'dI(V)_',num2str(iv_nbr),'.png']])
%end
%%

