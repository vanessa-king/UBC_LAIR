function [didv, norm_didv, ivcorr, Vred] = gridCorrNorm(grd, C, smooth)
%GRIDCORRNORM 
%   Detailed explanation goes here
%   if smooth = 0 no smoothing before treating data 
% An example: gridCorrNorm(grd, 3E-10, 1) 0 means do not smooth current (or spatial); 1 means do the smooth part

V = grd.V; % pick array V (201*1 double) from structure grd (1*1 struct)
iv = grd.iv; % pick array iv (201*120*120 double) from structure grd (1*1 struct)
Vred = V(1:end-1); % why here is end-1? any physical meaning? ( now only pick 200*1 double)

% correct for (I,V)=(0,0)
% find the smallest bias and set that to zero
%=============================================
if find(diff(sign(V))) % here find(diff(sign(V))) == 100
    [~,ind] = min(abs(V)); %here only show the index position of the minium value, ind=101,~ means do not show anything
    ivcorr = NaN(size(iv)); % build up a NaN matrix (201 120 120)
    for kx = 1:size(iv,2) %here kx=1:120
        for ky = 1:size(iv,3) %here kx=1:120
            ivcorr(:,kx,ky) = iv(:,kx,ky)-iv(ind,kx,ky); %here the find the mimumum array of V
        end
    end
else
    ivcorr = iv;
end

if smooth
    ivcorr = smoothdata(ivcorr, 1, 'gaussian', 10);
end
%=============================================

% differentiate and normalise the data
%=============================================
didv = NaN(length(Vred),size(iv,2),size(iv,3));
norm_didv = NaN(length(Vred),size(iv,2),size(iv,3));

for kx = 1:size(iv,2)
    for ky = 1:size(iv,3)
        didv(:,kx,ky) = diff(ivcorr(:,kx,ky))./diff(V); % just didv not normalised
        normtemp = sqrt((ivcorr(1:length(Vred),kx,ky)./Vred).^2+C^2);
        norm_didv(:,kx,ky) = didv(:,kx,ky)./normtemp; % didv normalised
    end
end


end
%=============================================
