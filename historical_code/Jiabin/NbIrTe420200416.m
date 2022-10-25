%%
% (1) This section of code loads the necessary script directories, data paths,
% and files to be analyzed.
%

%add relevant script directories
root_folder = 'C:\Users\jamesday\Documents\UBC\Data\CaPt\Tesla-Code\Tesla-Code';
addpath([root_folder '\omicron']); %QUESTION FOR JISUN: DO WE ACTUALLY USE THIS FOLDER?
addpath([root_folder '\custom_scripts']);
addpath([root_folder '\colourmaps'])

% add data path
addpath([root_folder '\data']);
addpath([root_folder '\output'])
fld = '.';

% stamp_project is the filename leader and takes the form 'yyyymmdd-XXXXXX_CaPt--STM_Spectroscopy--'; 
stamp_project = '20210827-184700_CaPt--STM_Spectroscopy--'; 

%set the iv-file name
iv_nbr = '51_1';

%set the z-file (aka topo) name
img_nbr = '207_1';

%points per sweep is set
pointsPerSweep = 500;

%seconds per sample is set
Traster = 11.33 * 10^(-3); 

%%
% (2) This section of code loads the files called above (iv_nbr and img_nbr),
% in either the upward or downward direction, to create "grd". Only one of upward or downward should be used.
%

avg_forward_and_backward = false;
grd = gridLoadDataUpward(fld,stamp_project,img_nbr,iv_nbr, avg_forward_and_backward);
% grd = gridLoadDataDownward(fld,stamp_project,img_nbr,iv_nbr, avg_forward_and_backward);

%%
% (3a) This section of code first gets a time axis to plot against i(v) or di/dv.
% Second, it applies moving-average smoothing to the di/dv data vs time.
%

time = getTimeAxis(pointsPerSweep, Traster);
grd.iv = gridSmooth(grd.iv,time); % requires Curve Fitting Toolbox
if (~avg_forward_and_backward)
    grd.ivForward = gridSmooth(grd.ivForward,time); 
    grd.ivBackward = gridSmooth(grd.ivBackward,time);
end
%%
% (3b) This section of code will does some funny vertical shifting. Dong will talk to
% Sarah about its purpose, as it's not clear that we need this.
%

[didv, norm_didv, ivcorr, Vred] = gridCorrNorm(grd, 3E-10, 0); 
if (~avg_forward_and_backward)
    grdForward = grd;
    [grdForward.iv] = grdForward.ivForward;
    [didv_forward, ~, ~, ~] = gridCorrNorm(grdForward, 3E-10, 0);
    grdBackward = grd;
    [grdBackward.iv] = grdForward.ivBackward;
    [didv_backward, ~, ~, ~] = gridCorrNorm(grdBackward, 3E-10, 0);
end
%% 
% (4) This section of code takes the average of the iv data (e.g., the whole
% grid) and plots both "i versus v" and "di/dv versus v"
%
% NOTE: IF I DON'T RUN THE SECTION ABOVE, THIS SECTION DOESN'T RECOGNIZE
% VRED

[elayer, ~] = size(Vred);

% This makes the "i versus v" plot
avg_iv_forward = gridAvg(grd.ivForward, grd.V);
fig = gcf;
close(fig);
gridAvg(grd.ivBackward, grd.V);
title('grid file207-1') %make certain that this title name is updated
hold on
plot(grd.V,avg_iv_forward)
hold off
legend('bwd', 'fwd');
ylabel('I(V) [a.u.]')

% This makes the "di/dv versus v" plot
avg_didv_forward = gridAvg(didv_forward, Vred);
fig = gcf;
close(fig);
gridAvg(didv_backward, Vred);
hold on
plot(Vred,reshape(avg_didv_forward(:),elayer,1))
title('topo file 51-1') %make certain that this title name is updated
hold off
legend('bwd', 'fwd');
ylabel('dI/dV [a.u.]')
%%
% (5) This section of code plots the few selected di/dv, depending on where
% the user clicked, and saves them. The main toggle here is the fourth input which defines
% the number of point spectra to plot.
%

gridClickForSpectrum(didv,Vred,0,2,0,0,0,grd) % requires the Image Processing Toolbox

set(gca,'FontSize',20,'XLim',[-0.05,0.05],'YLim',[0,4E-9]);

saveas(gca,[root_folder, '\output', '/grid',iv_nbr,'I(V)-A.png']) %make sure to update the saved filename

%%
% (6) This section of code takes a slice of di/dv at certain energy,
% defined by the user, and saves it.
%

gridPlotSlices(didv,Vred,0.0047,'tryyy'); %be sure to set the energy you want (third input) and make certain that this title name is set appropriately

saveas(gca,[root_folder, '\output', '/grid_fullCaPt10-4-8_',stamp_project,'I(V)_32.png']) %make sure to update the saved filename
%%
% (7) This section of code makes a movie of all energy slices from grid
% measurement and saves it.
%

v = VideoWriter([root_folder, '\output', '/grid_CaPt10-4-8_Tmovie_',stamp_project,'I(V)_',num2str(iv_nbr),'.avi']);
gridMovie(didv, Vred, v); 

%%
% (8) This section of code thresholds a grid of i(v) data at a specific
% bias either through the median or a custom value. This sectioning is shown as a boundary on
% di/dv, as well as separate "bright" and "dark" spectra.
%

% Enter the bias value here
bias = 0.0047;

% This sets the energy threshold
[iv_threshold, bright_indices, dark_indices, boundary_x, boundary_y] = gridGetThreshold(didv, Vred, bias);
avg_iv_bright = gridAvgFilter(didv, Vred, bright_indices);
avg_iv_dark = gridAvgFilter(didv, Vred, dark_indices);

% This makes the "bright" and "dark" spectra plots
figure();
plot(Vred,avg_iv_bright)
hold on
plot(Vred, avg_iv_dark)
ylabel('dI/dV [a.u.]','fontsize', 20)
xlabel('V','fontsize', 20)
xticks([-0.04 -0.02 0 0.02 0.04])
ylim([0 3e-9])
set(gca,'fontsize',20)
legend("Bright", "Dark",'fontsize', 20);
axis square
hold off
%%
% (9) This section of code subtracts the plane in the topographic image. It
% also overlays a boundary (in energy space) over the topographic image.
%

didv_flip = flip(permute(didv,[1 3 2]),2); % flip didv so that image (x,y) = (0,0) at the bottom left
topo = topoPlaneSub(grd,200,0); % subtract plane
fig_name = 'Topology associated with grid';
z_img = flip(permute(topo,[2 1]),1);
fig_plot = imresize(z_img, [size(didv_flip,2), size(didv_flip,3)]);
img = figure('Name', fig_name); imagesc(fig_plot); colormap('gray'); hold on
axis image
hold on;
plot(boundary_x, boundary_y, 'r', 'LineWidth', 2);
hold off
%%
% (10,11) This section of code finds average di/dv with with index filter
% applied. Note that it contains two custom scripts in "topoGetThreshold"
% and "gridAvgFilter".
%

% This sets the height threshold
[height_threshold, tall_indices, short_indices, boundary_x, boundary_y] = topoGetThreshold(topo);
avg_iv_tall = gridAvgFilter(didv, Vred, tall_indices);
avg_iv_short = gridAvgFilter(didv, Vred, short_indices);

%This makes the plots
figure();
plot(Vred,avg_iv_tall)
hold on
plot(Vred, avg_iv_short)
title("Average dI/dV for tall and short");
xlabel("V")
ylabel("Avg iv data")
legend("Tall", "Short");
axis square
hold off


%%
% (12,13) This section of code creates a circular mask of radius R around a
% clicked point. It then plots the average di/dv on that point. The user may toggle R and energy slice.
%
% THIS SECTION IS CURRENTLY STRUCTURED FOR DONOR AND ACCEPTOR ENERGIES, SO
% WE WILL WANT TO MODIFY THIS ACCORDINGLY.

% plots di/dv at the specified energy (thrid input) and allows user to
% click on a point with a mask of radius R (fourth input)
A_mask = gridMaskPoint(didv, Vred, 0.0055, 1);
D_mask = gridMaskPoint(didv, Vred, -0.0019, 1);

% takes the average of the di/dv spectra in the selected area
[~, A_sts] = gridAvgMask(didv, A_mask);
[~, D_sts] = gridAvgMask(didv, D_mask);

% plots the spectra at the spots where the masks were applied
figure; hold on;
set(gca,'DefaultLineLineWidth',2)
set(gca,'FontSize',20)
plot(Vred, D_sts); 
plot(Vred, A_sts);  
xlim([-0.02, 0.02])
ylim([0, 4E-9])
legend('negative','positive')
xlabel('Bias (V)')
ylabel('dI/dV a.u.)')
hold off
%

%%
% (TBD) This section of code should run like the previous one, but here you
% click two points that define a single rectangle (presumably, opposite
% corners).
%
%
% plot the averaged didv on square

B_mask = gridMaskSquare(didv, Vred, 0.0019);
%gridMaskSquare Make a mask based on rectangle drawn on didv
%   Define 2 points that makes up a rectangle the will be the mask.
%   mask = mask of selected area
%   N = number of points included in mask
%   imV = bias slice to show and click on

[~, B_sts] = gridAvgMask(didv, B_mask);

% plot figures
figure; hold on;
set(gca,'DefaultLineLineWidth',2)
set(gca,'FontSize',20)
plot(Vred, B_sts); 
xlim([-0.05, 0.05])
%legend('Donor','Acceptor','Au')
legend('average didv on square')
xlabel('Bias (V)')
ylabel('dI/dV')
hold off


%%
% (TBD) I have never used this one... Also, it is in this section and below
% that some errors (see orange bars to the side) start popping up.
%
%

for k=1:200 % picking 200 energy evenly, from IV direclty, 200 didv 0 is missing.
    didv2(:,:,k) = didv(k,:,:); %arrange as (x,y,k)
    Med(k) = median(median(didv2(:,:,k))); %median twice, pick one specific peak in histogram
    sg(k) = std(std(didv2(:,:,k))); %  Standard deviation twice with the peak
end

%% For real space grid map
%
% (TBD) I have never used this one...
%

% eint=1;
% for k=1:200/eint
% %     energy = -202+2*k;
for k=1:50
    const=50; % constant number for caxis contrast.
    energy = -202+2*k;
%     figure(13)
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

%% From real space image to QPI
%
% (TBD) Again, haven't used it yet...
%

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
%
% (TBD) Another as-of-yet unused one...
%

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
%
% (TBD) Here be dragons.
%

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
%
% (TBD) More dragons.
%

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

