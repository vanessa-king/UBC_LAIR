function [QPI_symm, QPI_symm_45] = Symmetrizing2(QPI, bragg_slice)
% Description: 
%   Function takes cropped QPI, locates Bragg peaks on bragg_slice, and symmetrises in a
%   four-fold manner (x, y, and xy reflection)
%   Outputs symmetrised QPI, and rotated symmetrised QPI

% Input: 
%   QPI: input QPI
%   bragg_slice: the bias slice where the bragg peak is most prominent.
% Output: 
%   QPI_symm: QPI after symmetrizing
%   QPI_symm_45: QPI_symm rotated 45 degrees

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
tform = fitgeotrans([ col3 row3;  col4 row4;  col2 row2; col1 row1],[0 320; 318 320; 318 0; 0 0],'projective');

% perform transform

fprintf('Performing transform \n')
D(:,:,:) = imwarp(QPI(:,:,:), tform);
[lx, ly, lz] = size(D);
D = zeros(lx,ly,lz);

for i = 1:size(QPI,3)
    D(:,:,i) = imwarp(QPI(:,:,i), tform);
end

%%
% Make a square matrix via padding, here it is only useful when QPI
% does not have same dimension in x and y. 

if lx > ly
    D_int_pad = zeros(lx,lx,lz);
    for i = 1:lx
        for j = 1:ly
            for k = 1:lz
                D_int_pad(i,j+round((lx-ly)/2),k) = D(i,j,k);
            end
        end
    end
elseif ly > lx
    D_int_pad = zeros(ly,ly,lz);
    for i = 1:lx
        for j = 1:ly
            for k = 1:lz
                D_int_pad(i+round((ly-lx)/2),j,k) = D(i,j,k);
            end
        end
    end
else
    D_int_pad(:,:,:) = D(:,:,:);
end
    
%% Symmetrizing flip around x,y and x+y
% 
% fprintf('Symmetrizing the data \n')
% [d_lx, d_ly, d_lz] = size(D_int_pad);
% 
% D90 = zeros(d_lx, d_ly, d_lz);
% QPI_symm = zeros(d_lx, d_ly, d_lz);
% 
% for k = 1:lz
%     D90(:,:,k) = imrotate(D_int_pad(:,:,k),90);
%     QPI_symm(:,:,k) = imrotate(D_int_pad(:,:,k),90) + imrotate(D_int_pad(:,:,k),180) + ...
%         imrotate(D_int_pad(:,:,k),270) + flip(D_int_pad(:,:,k),1) + flip(D_int_pad(:,:,k),2) + ...
%         flip(flip(D_int_pad(:,:,k),1),2) + flip(D90(:,:,k),1) + flip(D90(:,:,k),2) + ...
%         flip(flip(D90(:,:,k),1),2);
% end
% 
% QPI_symm = circshift(QPI_symm,100,3);
% 

%% Symmetrizing flip around x,y

fprintf('Symmetrizing the data \n')
[d_lx, d_ly, d_lz] = size(D_int_pad);

QPI_symm = zeros(d_lx, d_ly, d_lz);

for k = 1:lz
    QPI_symm(:,:,k) = (D_int_pad(:,:,k) + flip(D_int_pad(:,:,k),1) + flip(D_int_pad(:,:,k),2) + ...
        flip(flip(D_int_pad(:,:,k),1),2))/4;
end

%QPI_symm = circshift(QPI_symm,100,3); %why does brandon do that?

%%

for k = 1:lz
    QPI_symm_45(:,:,k) = imrotate(QPI_symm(:,:,k),45);
end

end