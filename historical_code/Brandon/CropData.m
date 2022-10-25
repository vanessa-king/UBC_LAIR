function [dIdV_cropped, QPI_cropped] = CropData(dIdV_nostreaks)

% Function removes data outside a user specified box, defined by two points
% Takes streak removed dIdV
% Outputs cropped dIdV and resultant FT QPI map

% Display image to create cropping box
clims = [min(min(dIdV_nostreaks(:,:,75))) 0.25*max(max(dIdV_nostreaks(:,:,75)))];
figure(1)
imagesc(dIdV_nostreaks(:,:,75),clims)
pbaspect([1 1 1])
[x,y] = ginput(2); % Two clicks define cropping box (top left, bottom right)

%%
% Round to the nearest odd integer for symmetrizing purposes
dIdV_cropped(:,:,:) = dIdV_nostreaks(2*round(y(1)/2)+1:2*round(y(2)/2)-1,2*round(x(1)/2)+1:2*round(x(2)/2)-1,:); 
% Take FT for QPI map
QPI_cropped(:,:,:) = abs(fftshift(fft2(dIdV_cropped(:,:,:) - mean(mean(dIdV_cropped(:,:,:))))));

end