function [didv_masked, didv_avg] = gridAvgMask(didv, mask)

% Description: this function is for taking the average of the selected area(Mask); this function always combined with the previous function:'gridMaskPoint'

%gridAverageMask Average specified area in the didv spectra
%   Apply the mask, and average over points. 
%   Mask should be a boolean matrix of same spatial size as didv.

%   didv = didv sprectra of the whole map
%   mask = selected area, parameter is from the function 'gridMaskPoint'
%   didv_masked = what the mask looks like
%   didv_avg = averaged didv, can be plotted over bias

didv_masked = didv;

% points to average over
[xrow,ycol] = find(mask);
didv_avg = zeros(size(didv,1),1); % average over points

for k = 1:size(didv,1)
    didv_masked(k,:,:) = squeeze(didv(k,:,:)).*mask; % here is the mask
    for i = 1:length(xrow)
        didv_avg(k) = didv_avg(k) + didv(k,xrow(i),ycol(i));
    end
end
didv_avg = didv_avg./length(xrow);



end

