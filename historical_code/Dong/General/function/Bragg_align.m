function [QPI_aligned] = Bragg_align(QPI, bragg_slice)
% Description: 
%   Function takes cropped QPI, locates Bragg peaks on bragg_slice
%   Outputs aligned QPI
% Input: 
%   QPI: input QPI
%   bragg_slice: the bias slice where the bragg peak is most prominent.
% Output: 
%   QPI_aligned: QPI after alignment 
%% Find quadrant points

[x_num_cropped, y_num_cropped] = size(QPI(:,:,bragg_slice));

%% Find the location of the Bragg peaks(in imagesc_QPI )

%
%   x3          x4
%
%
%
%
%   x1          x2
%

fprintf('Finding Bragg peaks \n')

% Bragg peak for (-1,-1) quad in the plotted QPI since imagesc flip y axis 

val1 = max(max(QPI(1:round(0.45*x_num_cropped),1:round(0.45*y_num_cropped),bragg_slice)));
[row1, col1] = find(QPI(1:round(0.45*x_num_cropped),1:round(0.45*y_num_cropped),bragg_slice) == val1);

% Bragg peak for (1,-1)

val2 = max(max(QPI(1:round(0.45*x_num_cropped),round(0.55*y_num_cropped):y_num_cropped,bragg_slice)));
[row2, col2] = find(QPI(1:round(0.45*x_num_cropped),round(0.55*y_num_cropped):y_num_cropped,bragg_slice) == val2);
col2 = col2 + round(0.55*y_num_cropped) - 1;

% Bragg peak for (-1,1)

val3 = max(max(QPI(round(0.55*x_num_cropped):x_num_cropped, 1:round(0.45*y_num_cropped),bragg_slice)));
[row3, col3] = find(QPI(round(0.55*x_num_cropped):x_num_cropped, 1:round(0.45*y_num_cropped),bragg_slice) == val3);
row3 = row3 + round(0.55*x_num_cropped) - 1;

% Bragg peak for (1,1)

val4 = max(max(QPI(round(x_num_cropped/2):x_num_cropped,round(y_num_cropped/2):y_num_cropped,bragg_slice)));
[row4, col4] = find(QPI(round(x_num_cropped/2):x_num_cropped,round(y_num_cropped/2):y_num_cropped,bragg_slice) == val4);
col4 = col4 + round(y_num_cropped/2) - 1;
row4 = row4 + round(x_num_cropped/2) - 1;
%%
% Create transform matrix

fprintf('Creating transform mtrix \n')
% tform = fitgeotrans([ col1 row1;  col2 row2;  col4 row4; col3 row3],[0 0; 0 100; 100 100; 100 0],'projective');
% tform = fitgeotrans([ col1 row1;  col2 row2;  col4 row4; col3 row3],[0 0; 0 301; 301 301; 301 0],'projective');
tform = fitgeotrans([ col3 row3;  col4 row4;  col2 row2;  col1 row1],[0 200; 200 200; 200 0; 0 0],'projective');

% perform transform

fprintf('Performing transform \n')
D(:,:,:) = imwarp(QPI(:,:,:), tform);
[lx, ly, lz] = size(D);
D = zeros(lx,ly,lz);
QPI_aligned = zeros(lx,ly,lz);

for i = 1:size(QPI,3)
    D(:,:,i) = imwarp(QPI(:,:,i), tform);
    QPI_aligned(:,:,i)=D(:,:,i);
end

%% Crop the data to only include the data within the Bragg peaks

%pad = 0;

%QPI_aligned_cropped(:,:,:) = QPI_aligned((col1 - pad):(size(QPI,1) - col4 + pad),(row1 - pad):(size(QPI,1) - row4 + pad),:);
end