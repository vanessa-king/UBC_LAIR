function [dIdV_nostreaks, QPI_nostreaks] = RemoveStreaks(dIdV)
% Description: 
%   Function takes 2D dIdV map and removes tip changes
%   Outputs fixed dIdV as well as FT QPI map
%   Valid only if peaks in dIdV occur at same position in all tip configs
%   Effectively normalises each line in the scan
%   Also fixes tip changes occuring during scan line

% Input:
%   dIdV: dIdV arrary from the load3ds (xsize*ysize*elayer arrary).
% Output: 
%   dIdV_nostreaks: dIdV after removing the streaks (xsize*ysize*elayer arrary). 
%   QPI_nostreaks: 2D FFT of dIdV_nostreaks. 

x_num = size(dIdV,1); % x-direction scan size
y_num = size(dIdV,2); % y-direction scan size
points = size(dIdV,3); % number of points in bias sweep

%% dIdV with no streaks

fprintf('Performing streak removal algorithm \n')

% Create empty variable for streak removal algorithm
dIdV_nostreaks = zeros(x_num, y_num, points); 

% for loop averages each scan line to zero
for k = 1:(points)
    col_mean = mean(dIdV(:,:,k),1);
    row_mean = mean(dIdV(:,:,k),2);
    totalcol_mean = mean(col_mean);
    totalrow_mean = mean(row_mean);
    for i = 1:x_num
        dIdV_nostreaks( i,:,k) = dIdV(i,:,k) - row_mean(i) + totalrow_mean;
    end
    for j = 1:y_num
        dIdV_nostreaks(:,j,k) = dIdV(:,j,k) - col_mean(j) + totalcol_mean;
    end
end

% for loop finds abrupt tip changes during a scan line
% fcn findchangepoints is MATLAB built in, locates step edges
% if statement renormalises each line to average at zero
% for a = 1:size(dIdV_nostreaks,2)
%     clear ipt
%     
%     ipt = findchangepts(normalize(dIdV_nostreaks(:,a,1)),'Statistic','mean','MinThreshold',10);
% 
%     ipt = [1; ipt; size(dIdV_nostreaks,1)];
% 
%     % Normalize lines
% 
%     if size(ipt,1) > 2
%         for k = 1:(size(ipt,1)-1)
%             for b = 1:(size(dIdV_nostreaks,3))
%                 dIdV_nostreaks(ipt(k):ipt(k+1),a,b) = dIdV_nostreaks(ipt(k):ipt(k+1),a,b) - mean(mean(mean(dIdV_nostreaks(ipt(k):ipt(k+1),a,b))));
%             end
%         end
%     end
% end

% TAKE FOURIER TRANSFORM OF THE dIdV DATA with streaks removed
% 1. Subract the mean to remove the zero frequency spike
% 2. 2D fast Fourier transform using the FFT2 function
% 3. Shift the FFT2 result so zero frequency is at the center
% 4. Take modulus for plotting the intensity

fprintf('Fourier transforming \n')

QPI_nostreaks = zeros(x_num, y_num, points); % Create zero matrix for QPI results

for i = 1:(points)
    QPI_nostreaks(:,:,i) = abs(fftshift(fft2(dIdV_nostreaks(:,:,i) - mean(mean(dIdV_nostreaks(:,:,i))))));
end


