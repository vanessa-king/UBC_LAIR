% Description: this function is for averaging the didv spectra in the selected area(area type depending on the Mask); 
%  Remark: Mask should be a boolean matrix of same spatial size as didv. this function always combined with the previous function:'gridMaskPoint'

function [didv_masked, didv_avg, comment] = gridAvgMask(didv, mask)

% parameters
%   didv = didv sprectra of the whole map
%   mask = selected area, parameter defined in the function 'gridMaskPoint'

comment = sprintf("gridAvgMask(didv:%s, mask:%s)|", mat2str(size(didv)), mat2str(size(mask)));

didv_masked = didv;

% points to average over
[xrow,ycol] = find(mask);
didv_avg = zeros(size(didv,1),1); 

for k = 1:size(didv,1)
    didv_masked(k,:,:) = squeeze(didv(k,:,:)).*mask; % here is the mask
    for i = 1:length(xrow)
        didv_avg(k) = didv_avg(k) + didv(k,xrow(i),ycol(i)); % average over points
    end
end
didv_avg = didv_avg./length(xrow);
end
