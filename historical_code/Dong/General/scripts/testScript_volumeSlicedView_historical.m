%% Define datacube
dataCube = QPI;  % Replace with your actual data

%% Parameter set
%define point and angle
 point =round(size(dataCube, [1 2 3])./2);
 %point=[];
 theta = [];
 phi = [1];
 eslice= 50;

%% make slice 
[cuboidMaskThree, commentThree] = volumeMaskZslice(dataCube, eslice, point, phi);
% 3d plot 
[s, cuboidMask, comment] = volumeMaskedZslicePlotManual(dataCube, eslice, point, phi);
figure()
%define energy range
% energy_range=1000*bias(2:end,1); %(use this for the QPI data)
energy_range=linspace(-500,1500,size(dataCube,3));
colormap(gray) 
[s1,comment1] = volumeMaskedZslice2Dplot_Dong(dataCube,cuboidMaskThree,energy_range);
title(sprintf("point at [%d, %d, %d] theta=%d phi=%d", point(1),point(2),point(3),theta, phi))

%% slice through 2 bragg peaks 

%% Determine which slice to choose
% QPI viewer_energy slice specific color scale 
figure()
load('InverseGray','invgray')
qpi=QPI;
map = invgray;
for k=1:size(qpi,3)
   MaxValue = 0.8*max(qpi(:,:,k),[],'all');
   MinValue = 0.8*min(qpi(:,:,k),[],'all');
   energy_sliced_QPI(:,:,k,:) = mat2im(qpi(:,:,k), map, [1.2*MinValue 0.8*MaxValue]);
end
imshow3D(energy_sliced_QPI)

%% choose slice and run 
eslice= 110;

% Normalize dataCube image
load('InverseGray','invgray')
map = gray;
SliceMaxValue = 0.8*max(dataCube(:,:,eslice),[],'all');
SliceMinValue = 0.8*min(dataCube(:,:,eslice),[],'all');
Normalized_dataCube=mat2gray(dataCube(:,:,eslice),[1.2*SliceMinValue 0.8*SliceMaxValue]);
%find the first bragg peak
[~, row, col]=findlocalmax(Normalized_dataCube);
pointA=[row(1),col(1)];

%find the second bragg peak
[~, row, col]=findlocalmax(Normalized_dataCube);
pointB=[row(1),col(1)];

%% Specify points if needed
pointA=[82,1];
pointB=[1,82];
%% Make a 3D mask cuboid 
% produce mask 
[mask, ~, startPoint, endPoint] = gridMaskLine_new(dataCube(:,:,eslice), pointA, pointB);

% Manually Perform x-mirrow for the mask
%mask=flip(mask,1);

% Expand the 2D mask to a 3D Mask
cuboidMask= logical(ones(size(dataCube)).*mask); 

% Verify the mask location
[row,col] = find(mask);

for i =1:size(row)
    Normalized_dataCube(row(i),col(i))=1;
end
figure();
imshow(Normalized_dataCube)

%% Apply mask to make a slice cut
% 3D plot
figure()
[s, cuboidMask, comment] = volumeMaskedZslicePlot_3D(dataCube, cuboidMask, eslice);

%% 2D plot 
energy_range=1000*bias(1:size(bias,1)-1,1); %(use this for the QPI data)
figure()
colormap(gray) 
[s1,comment1] = volumeMaskedZslice2Dplot_Dong(dataCube,cuboidMask,energy_range);
title("slice through a/c")

%% Compute norm of a vector in q space 
% parameter setting:
center=[1+size(dataCube,1)/2,1+size(dataCube,2)/2];
realspace_size=40;
pixel_num=size(dataCube,1);
point1=center;
point2=pointA;

% compute pixel norm
pixel_norm=norm(point1-point2);

% translate into inverse nm
inverse_nm = pixel_norm/pixel_num*(1/(realspace_size/pixel_num));
nm = 1/inverse_nm

 
%% DFT 2D plot
energy_range=linspace(1,size(dataCube,3),size(dataCube,3)); %(use this for the QPI data)
figure()
colormap(gray) 
[s1,comment1] = volumeMaskedZslice2Dplot_Dong(dataCube,cuboidMask,energy_range);
title("vertical cut of DFT")





