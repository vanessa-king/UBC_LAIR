%% Code Source: Built by Dong based on Brandon's & Seokhwan's code
%% Description: This code is made for the Grid data processing
%% DATA LOADING
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Load the .3ds data

% INPUTS
% 1: Data file to load, including file type ('QPI.3ds' for example)
% 2: Smoothing sigma for current data

% OUTPUTS
% header: Variable containing all experimental parameters
% I: Current data, smoothed by sigma
% dIdV: Numerically differentiated current data
% voltage: Vector of voltages for current
% midV: Vector on voltages for dIdV/QPI (midpoint of voltage vector)
% QPI: Fourier transformed dIdV data

% Modified function load3dsall from supplied matlab code from Nanonis
[header, par, I, dIdV, LockindIdV, bias, midV, QPI, LockinQPI] = load3dsall('Grid_20210906_HR_CZ.3ds', 5);
xsize = header.grid_dim(1);
ysize = header.grid_dim(2);
elayer = header.points;
estart = par(1);
eend = par(2);

%% DATA PROCESSING
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%% Simple Crop data
target_data=QPI;
target_slice=56;
mask= gridMaskRectangle(target_data(:,:,target_slice));
% make mask 3d
mask= mask*ones(size(target_data));
cropped_data= gridCropmask(target_data, mask);
%% Removes streaks in the dIdV& LockindIdV
% disclaim: use on a flat surface

% INPUTS
% 1: dIdV 

% OUTPUTS
% dIdV_nostreaks: dIdV with streak removal algorithm applied
% QPI_nostreaks: Fourier transformed dIdV_nostreaks

[dIdV_nostreaks, QPI_nostreaks] = RemoveStreaks(dIdV);
[LockindIdV_nostreaks, LockinQPI_nostreaks] = RemoveStreaks(LockindIdV);
%% Mask any defects present in the material

% [y1, y2] = masking(x1, x2, x3)

% INPUTS
% 1: dIdV 3x3 matrix
% 2: Voltage vector to index match the chosen image voltage
% 3: Voltage to display dIdV to mask data

% OUTPUTS
% dIdV_masked: dIdV with Gaussian masking over chosen defects
% QPI_masked: Fourier transformed dIdV_masked

% HOW TO
% Click defect you want to mask, then hit y to continue to mask another
% defect, or n to stop the masking process

%[dIdV_masked, QPI_masked] = masking(dIdV,midV,450);
%[LockindIdV_masked, LockinQPI_masked] = masking(LockindIdV_nostreaks,midV,-100);
[dIdV_masked, QPI_masked] = masking(dIdV,midV,-100);
%[LockindIdV_masked, LockinQPI_masked] = masking(LockindIdV_nostreaks,midV,200);

%% Crop the dIdV data to remove new line drift

% INPUTS
% dIdV_nostreaks: dIdV matrix after streak removal algorithm

% OUTPUTS
% dIdV_cropped: dIdV with no edge drift
% QPI_cropped: Fourier transformed dIdV_cropped

% HOW TO
% create a box to crop from two user defined points. First point in upper
% left, second in bottom right

% comment 
[dIdV_cropped, QPI_cropped] = CropData(dIdV);
%[LockindIdV_cropped, LockinQPI_cropped] = CropData(LockindIdV_masked);
%% Align the bragg peaks of the data 

% INPUTS
% QPI: QPI data after removing new line drift

% OUTPUTS
% QPI_aligned: Symmetrized QPI with Bragg peaks off axis

[QPI_aligned] = Bragg_align(QPI,56);
%[LockinQPI_aligned] = Bragg_align(LockinQPI,25);

%% Crop the aligned data

% INPUTS
% QPI_aligned: aligned QPI data

% OUTPUTS
% QPI_aligned_crop: QPI_aligned but cropped to the Bragg peaks

[QPI_aligned_crop] = Crop_Symm_QPI_45(QPI_aligned,250);
%[LockinQPI_aligned_crop] = Crop_Symm_QPI_45(LockinQPI_aligned,25);
%% Apply Q=-Q symmetry 

% Rotate the image 180 degrees and add to itself. 
% mathmatically, it does nothing 

%for k = 1:size(bias,1)
%    LockinQPI_pointsymm(:,:,k) = (LockinQPI_aligned_crop(:,:,k)+imrotate(LockinQPI_aligned_crop(:,:,k),180))/2;
%end
 
QPI_pointsymm=zeros(size(QPI_aligned_crop,1),size(QPI_aligned_crop,2),size(QPI_aligned_crop,3));
for k = 1:size(QPI_aligned_crop,3)
    QPI_pointsymm(:,:,k) = QPI_aligned_crop(:,:,k)+imrotate(QPI_aligned_crop(:,:,k),180);
end
%% Symmetrize the data

% INPUTS
% QPI: QPI data 

% WARNING: know your crystal symmetry on the surface to implement this section
% OUTPUTS 
% QPI_symm: Symmetrized QPI with Bragg peaks off axis
% QPI_symm_45: Symmetrized QPI rotated 45 deg w.r.t. QPI_symm

[QPI_symm] = Symmetrizing2(QPI,121);
%[LockinQPI_symm] = Symmetrizing2(LockinQPI_nonstreaks,100);

%% Crop the symmetrized data

% INPUTS
% QPI_symm_45: Symmetrized QPI data

% OUTPUTS
% QPI_symm_45_crop: QPI_symm_45 but cropped to the Bragg peaks

[QPI_symm_crop_45] = Crop_Symm_QPI_45(QPI_symm);
%[LockinQPI_symm_crop_45] = Crop_Symm_QPI_45(LockinQPI_symm);
%% Crop QPI from center 

targetSize=[100 100 139];
win = centerCropWindow3d(size(QPI),targetSize);
QPI_centercropped = imcrop3(QPI,win);

%% DATA Visualization 
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Plotting the real space Gridmap 
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Gridmap from Lockin signal 

LockindIdV_used= LockindIdV_masked;
for k=1:elayer 
    Grid(:,:,k) = LockindIdV_used(:,:,k);
    MeddIdV(k) = median(median(LockindIdV_used(:,:,k)));
    Stdv(k) = std(std(LockindIdV_used(:,:,k)));
end
%% Gridmap from dIdV signal 

dIdV_used= dIdV;
for k=1:elayer-1 
    Grid(:,:,k) = dIdV_used(:,:,k);
    MeddIdV(k) = median(median(dIdV_used(:,:,k)));
    Stdv(k) = std(std(dIdV_used(:,:,k)));
end
%% Gridmap viewer 
nos=5;

figure(3)
load('InverseGray','invgray')
map = invgray;
for k=1:size(Grid,3)
    MaxValue = max(Grid(:,:,k),[],'all');
    MinValue = min(Grid(:,:,k),[],'all');
    slicedglob_grid(:,:,k,:) = mat2im(Grid(:,:,k), map, [MeddIdV(k)-nos*Stdv(k) MeddIdV(k)+nos*Stdv(k)]);
end
imshow3D(slicedglob_grid)
%% Gridmap print out (png files)

nos=8;
egap=1000*(eend-estart)/(elayer-1);
path=eval(['[''Gridmap_nos=',num2str(nos),'/Gridmap/'']']); %change your file path here

mkdir(path);

for k=1:size(Grid,3)
    figure(3)
    imagesc((Grid(:,:,k)))
    hold on
    pbaspect([1 1 1])
    set(gcf,'Colormap',bone)
    caxis([MeddIdV(k)-nos*Stdv(k) MeddIdV(k)+nos*Stdv(k)]) % If you want to change 2D-gridmap contrast you can change nos value
    xticks([])
    yticks([])
    eval(['fname = [''Gridmap'',num2str(k,''%03u''),''_(r,E='', num2str(1000*estart+(k-1)*egap), ''mV).png''];'])   % File name with number label. You can change '-800+(k-1)*egap' part.
    F = getframe(gca);
    imwrite(F.cdata,[path,fname]); 
end
%% Plotting the Q space scattering map 
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% QPI from analysis_LockinQPI 

QPI_used=LockinQPI_nostreaks(:,:,:);
%% QPI from analysis_QPI 

QPI_used=QPI;
%% Log(QPI)  

QPI_used=log(QPI_used+1);
%% Data selection of QPI_used


qpi=QPI_used;
%% QPI viewer_global color scale

figure(4)
load('InverseGray','invgray')
map = invgray;
MaxValue = 0.8*max(qpi(:,:,:),[],'all');
MinValue = 0.8*min(qpi(:,:,:),[],'all');
energy_sliced_QPI(:,:,:,:) = mat2im(qpi(:,:,:), map, [1.2*MinValue 0.8*MaxValue]);
imshow3D(energy_sliced_QPI)

%% QPI viewer_energy slice specific color scale 

figure()
load('InverseGray','invgray')
map = invgray;
for k=1:size(qpi,3)
   MaxValue = 0.8*max(qpi(:,:,k),[],'all');
   MinValue = 0.8*min(qpi(:,:,k),[],'all');
   energy_sliced_QPI(:,:,k,:) = mat2im(qpi(:,:,k), map, [1.2*MinValue 0.8*MaxValue]);
end
imshow3D(energy_sliced_QPI)


%% Slice QPI 
% Could be integrated into a function 
%indicate the line we want to cut: output the 2 points on QPI
slice_number=139; 
QPI_center = [size(QPI,1)/2,size(QPI,2)/2,slice_number];


% reverse the color map to find the local max, if delete, it finds the
% local minimum 
target_energy_sliced_QPI= squeeze(energy_sliced_QPI(:,:,slice_number,1));
[~,row_max,col_max] = findlocalmax(1-(target_energy_sliced_QPI));
point = [mean(row_max),mean(col_max),slice_number];
vector_xy=point-QPI_center;
vector_z=[0,0,1];
normal=cross(vector_xy, vector_z);

%plot the sliced QPI 
[QPI_slice, x, y, z] = obliqueslice(QPI_used,point,normal);

figure
surf(x,y,z,QPI_slice,'EdgeColor','None','HandleVisibility','off');
grid on
view([-38 12])
colormap(gray)
xlabel('x-axis')
ylabel('y-axis');
zlabel('energy layer');
title('Slice in 3-D Coordinate Space')
hold on
plot3(point(1),point(2),point(3),'or','MarkerFaceColor','r');
plot3(point(1)+[0 normal(1)],point(2)+[0 normal(2)],point(3)+[0 normal(3)], ...
    '-b','MarkerFaceColor','b');
hold off
legend('Point in the volume','Normal vector')
%% Plot QPI

nos=8;
egap=1000*(eend-estart)/(elayer-1);
path=eval(['[''Gridmap_nos=',num2str(nos),'/QPI/'']']); %change your file name here 
mkdir(path);
load('InverseGray','invgray')

for k=1:size(qpi,3)
    figure(4)
    imagesc(qpi(:,:,k))
    hold on
    pbaspect([1 1 1])
    set(gcf,'Colormap',invgray) 
    xticks([])
    yticks([])
    eval(['fname = [''QPI'',num2str(k,''%03u''),''_(r,E='', num2str(1000*estart+(k-1)*egap), ''mV).png''];']) 
    F = getframe(gca);
    imwrite(F.cdata,[path,fname]); 
end
%% Plot combined Grid_QPI 

nos=8;
egap=1000*(eend-estart)/(elayer-1);
path=eval(['[''Gridmap_nos=',num2str(nos),'/20221027Grid&QPI/'']']); %change your file name here 
mkdir(path);
load('InverseGray','invgray')

for k=115:150
    j=k;
    f=figure();
    f.Position(3:4) = [1200 500];
    % Make tiles 
    tiledlayout(1,2)
    % Tile 1 
    nexttile
    imagesc(Grid(:,:,k));
    title(num2str(1000*estart+(k-1)*egap)+"mV")
    % Tile 2 
    nexttile
    imagesc(qpi(:,:,k));
    set(gcf,'Colormap',invgray) 
    hold on
    %pbaspect([1 1 1])
    drawnow
    ax = gca;
    ax.Units = 'pixels';
    pos = ax.Position;
    marg = 30;
    rect = [-marg-1.33*pos(3), -marg, 2.33*pos(3)+2*marg, pos(4)+2*marg];
    F = getframe(gca,rect);
    ax.Units = 'normalized';
    eval('fname = [''QPI'',num2str(j,''%03u''),''_(r,E='', num2str(1000*estart+(k-1)*egap), ''mV).png''];') 
    imwrite(F.cdata,[path,fname]); 
end
%% Calibrate the QPI wrt the reference plot 

path='Gridmap_nos=15/QPI';
photoB="000.png";
specific_plot='QPI060_(r,E=375.5396mV).png';
calibrate_batchA(path,photoB,specific_plot)

%% Plot QPI with certain biases

% write this as a function 
Target_bias=linspace(-0.5,0.5,101);
nos=10;
egap=1000*(eend-estart)/(elayer-1);
path=eval(['[''Gridmap_nos=',num2str(nos),'/QPI/','/013/','/masked/'']']); %change your file name here 
mkdir(path);
load('InverseGray','invgray')

for v=1:size(Target_bias,2)
    figure(4)
    [~,ind]=(min(abs(bias-Target_bias(v))));
    imagesc(qpi(:,:,ind))
    hold on
    pbaspect([1 1 1])
    set(gcf,'Colormap',invgray) 
    xticks([])
    yticks([])
    eval(['fname = [''QPI'',num2str(v,''%03u''),''_(r,E='', num2str(1000*estart+(ind-1)*egap), ''mV).png''];'])
    F = getframe(gca);
    imwrite(F.cdata,[path,fname]); 
end
%% Plot the scattering dispersion on a specific q axis
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Average over an axis around a certain q_center

qcenter=round(size(Grid,1)/2);
lineqy(:,:) = QPI_used(qcenter,:,1:45); 
%lineqy(:,:) = 3*QPI_used(qcenter - 2,:,:)+5*QPI_used(qcenter - 1,:,:)+5*QPI_used(qcenter,:,:)+3*QPI_used(qcenter + 1,:,:); 
% lineqy(:,:) = QPI(101,:,:); %arrange as (qx,k,qy)
%lineqx(:,:) = QPI(:,101,:); %arrange as (qx,k,qy)
%lineqx(:,:) = 3*QPI_used(:,qcenter - 2,:)+5*QPI_used(:,qcenter - 1,:)+5*QPI_used(:,qcenter,:)+3*QPI_used(:,qcenter + 1,:); 
lineqx(:,:) = QPI_used(:,qcenter,1:45);
%%
R_resolution=0.25; %(unit in Angstrom)
q_range=2*pi/R_resolution; %(unit in inverse Angstrom)
q_axis=[(-q_range/2), (q_range/2)];
e_axis=[round(estart*1000), round(eend*1000)];
subplot(1,2,1);
imagesc(q_axis,e_axis,rot90(lineqx(:,:)));
xlabel('qx(Angstrom^-1)')
ylabel('energy(meV)')
subplot(1,2,2)
imagesc(q_axis,e_axis,rot90(lineqy(:,:)));
xlabel('qy(Angstrom^-1)')
ylabel('energy(meV)')
hold on
   set(gcf, 'Colormap')
   xticks([])
   yticks([])
%% DFT calculation processing
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Load DFT slices at different Kz 
% specify data path 
%DFT_datapath="G:\Dong\OneDrive - phas.ubc.ca\300Science\320 PtSn4_phD\323 Data processing and plotting\Gridmap&QPI_processing\scripts\General\DFT.mat";

% load data
%DFT_data = load(DFT_datapath);
DFT_data = DFT_full;
% extract different Kz slices
DFT_data_kz1 = squeeze(DFT_data(1,:,:,:)); % kz1 correspond to kz= 0
DFT_data_kz2 = squeeze(DFT_data(2,:,:,:)); % kz2 correspond to kz= pi/4b
DFT_data_kz3 = squeeze(DFT_data(3,:,:,:)); % kz3 correspond to kz= pi/2b
DFT_data_kz4 = squeeze(DFT_data(4,:,:,:)); % kz4 correspond to kz= 3pi/4b
DFT_data_kz5 = squeeze(DFT_data(5,:,:,:)); % kz5 correspond to kz= pib 

%% self correlation of a DFT calculation slice

% specify the slice plot path
%DFT_imgpath ='G:\Dong\OneDrive - phas.ubc.ca\300Science\320 PtSn4_phD\323 Data processing and plotting\Gridmap&QPI_processing\scripts\General\Input_photo\DFT_3pi4b_490mV.jpg';
% read img from the path 
%DFT_img = imread(DFT_imgpath);

%% Load and calculate 
% specify which Kz slice you will use
data= DFT_data_kz4;
energy_layer_num=size(data,1);
xy_dim=size(data,2);
data_precorr=zeros(energy_layer_num,2*xy_dim,2*xy_dim);
data_selfcorr=zeros(energy_layer_num,4*xy_dim-1,4*xy_dim-1);
for i = 1: size(data,1)
    % data load 
    DFT_img = squeeze(data(i,:,:));
    % update the image with Cv2 symmetry
    DFT_img_cv2 = construct_cv2_img(DFT_img);
    % save the CV2 img
    data_precorr(i,:,:) = construct_cv2_img(DFT_img);
    % compute the self correlation and plot it
    data_selfcorr(i,:,:) = computeSelfCorrelation(DFT_img_cv2);
end 
data_precorr=permute(data_precorr,[2,3,1]);
data_selfcorr=permute(data_selfcorr,[2,3,1]);
%% JDOS viewer 

figure()
load('InverseGray','invgray')
map = jet;
for k=1:size(data_selfcorr,3)
   MaxValue_precorr = max(data_precorr(:,:,k),[],'all');
   MinValue_precorr = min(data_precorr(:,:,k),[],'all');
   MaxValue_selfcorr = max(data_selfcorr(:,:,k),[],'all');
   MinValue_selfcorr = min(data_selfcorr(:,:,k),[],'all');
   energy_sliced_precorr(:,:,k,:) = mat2im(data_precorr(:,:,k), map, [1.2*MinValue_precorr 0.8*MaxValue_precorr]);
   energy_sliced_corr(:,:,k,:) = mat2im(data_selfcorr(:,:,k), map, [1.2*MinValue_selfcorr 0.8*MaxValue_selfcorr]);
end
imshow3D(energy_sliced_precorr)
figure()
imshow3D(energy_sliced_corr)

%% Plot combined DFT_Selfcorr
DFT_estart=-500;
DFT_egap=10;
path=eval(['[''/DFT_Selfcorr_kz3/'']']);
mkdir(path);
load('InverseGray','invgray')

for k=1:size(data_precorr,3)
    j=k;
    f=figure();
    f.Position(3:4) = [1200 500];
    % Make tiles 
    tiledlayout(1,2)
    % Tile 1 
    nexttile
    imagesc(data_precorr(:,:,k));
    title(num2str(DFT_estart+(k-1)*DFT_egap)+"mV")
    % Tile 2 
    nexttile
    imagesc(data_selfcorr(:,:,k));
    set(gcf,'Colormap',jet) 
    hold on
    %pbaspect([1 1 1])
    drawnow
    ax = gca;
    ax.Units = 'pixels';
    pos = ax.Position;
    marg = 30;
    rect = [-marg-1.33*pos(3), -marg, 2.33*pos(3)+2*marg, pos(4)+2*marg];
    F = getframe(gca,rect);
    ax.Units = 'normalized';
    eval('fname = [''DFT'',num2str(j,''%03u''),''_(r,E='', num2str(DFT_estart+(k-1)*DFT_egap), ''mV).png''];') 
    imwrite(F.cdata,[path,fname]); 
end
