function [QPI_symm_crop] = Crop_Symm_QPI_45(QPI_symm, bragg_slice)
% Description: 
%   The function take the QPI data, crop it to the size within the bragg peaks(within the 4 quadrants). 

% Input: 
%   QPI_symm: input QPI with bragg peaks in 4 quadrants. 
% Output: 
%   QPI_symm_crop: QPI after the crop. 

%% Find the location of the Bragg peaks
%
%   x3          x4                 x1           x2
%                       
%                 imagesc
%                      --> 
%                       data file 
%   x1          x2                 x3           x4
%
% Bragg peak position x1

val1 = max(max(QPI_symm(1:round(size(QPI_symm,1)*0.48),1:round(size(QPI_symm,2)*0.48),bragg_slice)));%techinqually, here 0.45 can be any number close to 0.5
[row1, col1] = find(QPI_symm(1:round(size(QPI_symm,1)*0.48),1:round(size(QPI_symm,2)*0.48),bragg_slice) == val1);

% Bragg peak position x4
offset_row4 = round(size(QPI_symm,1)*0.52);
offset_col4 = round(size(QPI_symm,2)*0.52);

val2 = max(max(QPI_symm(round(size(QPI_symm,1)*0.52):size(QPI_symm,1),round(size(QPI_symm,2)*0.52):size(QPI_symm,2),bragg_slice)));
[row4, col4] = find((QPI_symm(round(size(QPI_symm,1)*0.52):size(QPI_symm,1),round(size(QPI_symm,2)*0.52):round(size(QPI_symm,2)),bragg_slice)) == val2);


%% Crop the data to only include the data within the Bragg peaks

pad = 0;

QPI_symm_crop(:,:,:) = QPI_symm((row1 - pad): (offset_row4+row4 - pad),(col1 - pad):(offset_col4+col4 - pad),:);
%%

%QPI_symm_crop(:,:,:) = circshift(QPI_symm_crop(:,:,:),100,3);

end