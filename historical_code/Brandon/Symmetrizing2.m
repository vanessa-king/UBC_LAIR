function [QPI_symm, QPI_symm_45] = Symmetrizing2(QPI_cropped)

% Function takes cropped QPI, locates Bragg peaks, and symmetrises in a
% four-fold manner (x, y, and xy reflection)
% Outputs symmetrised QPI, and rotated symmetrised QPI

%% Find quadrant points

[x_num_cropped, y_num_cropped] = size(QPI_cropped(:,:,100));


%% Find the location of the Bragg peaks

%
%   x1          x2
%
%
%
%
%   x3          x4
%

fprintf('Finding Bragg peaks \n')

% Bragg peak for (-1,1)

val1 = max(max(QPI_cropped(1:round(0.45*x_num_cropped),1:round(0.45*y_num_cropped),100)));
[row1, col1] = find(QPI_cropped(1:round(0.45*x_num_cropped),1:round(0.45*y_num_cropped),100) == val1);

% Bragg peak for (1,1)

val2 = max(max(QPI_cropped(1:round(0.45*x_num_cropped),round(0.55*y_num_cropped):y_num_cropped,100)));
[row2, col2] = find(QPI_cropped(1:round(0.45*x_num_cropped),round(0.55*y_num_cropped):y_num_cropped,100) == val2);
col2 = col2 + round(0.55*y_num_cropped) - 1;

% Bragg peak for (-1,-1)

val3 = max(max(QPI_cropped(round(0.55*x_num_cropped):x_num_cropped, 1:round(0.45*y_num_cropped),100)));
[row3, col3] = find(QPI_cropped(round(0.55*x_num_cropped):x_num_cropped, 1:round(0.45*y_num_cropped),100) == val3);
row3 = row3 + round(0.55*x_num_cropped) - 1;

% Bragg peak for (1,-1)

val4 = max(max(QPI_cropped(round(x_num_cropped/2):x_num_cropped,round(y_num_cropped/2):y_num_cropped,100)));
[row4, col4] = find(QPI_cropped(round(x_num_cropped/2):x_num_cropped,round(y_num_cropped/2):y_num_cropped,100) == val4);
col4 = col4 + round(y_num_cropped/2) - 1;
row4 = row4 + round(x_num_cropped/2) - 1;
%%
% Create transform matrix

fprintf('Creating transform mtrix \n')
tform = fitgeotrans([ col1 row1;  col2 row2;  col4 row4; col3 row3],[0 0; 0 301; 301 301; 301 0],'projective');

% perform transform

fprintf('Performing transform \n')
D(:,:,:) = imwarp(QPI_cropped(:,:,:), tform);
[lx, ly, lz] = size(D);
D = zeros(lx,ly,lz);

for i = 1:lz
    D(:,:,i) = imwarp(QPI_cropped(:,:,i), tform);
end

%%
% Make a square matrix via padding

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
    
%% Symmetrizing

fprintf('Symmetrizing the data \n')
[d_lx, d_ly, d_lz] = size(D_int_pad);

D90 = zeros(d_lx, d_ly, d_lz);
QPI_symm = zeros(d_lx, d_ly, d_lz);

for k = 1:lz
    D90(:,:,k) = imrotate(D_int_pad(:,:,k),90);
    QPI_symm(:,:,k) = imrotate(D_int_pad(:,:,k),90) + imrotate(D_int_pad(:,:,k),180) + ...
        imrotate(D_int_pad(:,:,k),270) + flip(D_int_pad(:,:,k),1) + flip(D_int_pad(:,:,k),2) + ...
        flip(flip(D_int_pad(:,:,k),1),2) + flip(D90(:,:,k),1) + flip(D90(:,:,k),2) + ...
        flip(flip(D90(:,:,k),1),2);
end

QPI_symm = circshift(QPI_symm,100,3);


%%

for k = 1:lz
    QPI_symm_45(:,:,k) = imrotate(QPI_symm(:,:,k),45);
end

end