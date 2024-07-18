function [dIdV_cropped, QPI_cropped] = CropData(dIdV)
% Description: 
%   Function removes data outside a user specified box, defined by two points
%   Takes streak removed dIdV
%   Outputs cropped dIdV and resultant FT QPI map

% Input:
%   dIdV: input dIdV arrary
% Output
%   dIdV_cropped: processed dIdV
%   QPI_cropped: 2D FFT of dIdV_cropped 

% Display image to create cropping box
clims = [min(min(dIdV(:,:,75))) max(max(dIdV(:,:,75)))];
figure(1)
imagesc(dIdV(:,:,75),clims)
pbaspect([1 1 1])
[x,y] = ginput(2); % Two clicks define cropping box (top left, bottom right)

%%
% Round to the nearest odd integer for symmetrizing purposes
dIdV_cropped(:,:,:) = dIdV(2*round(y(1)/2)+1:2*round(y(2)/2)-1,2*round(x(1)/2)+1:2*round(x(2)/2)-1,:); 
% Take FT for QPI map
QPI_cropped(:,:,:) = abs(fftshift(fft2(dIdV_cropped(:,:,:) - mean(mean(dIdV_cropped(:,:,:))))));

end