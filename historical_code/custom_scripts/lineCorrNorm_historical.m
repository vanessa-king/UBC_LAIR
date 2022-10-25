function [didv, norm_didv, ivcorr, Vred] = lineCorrNorm(line, C, smooth)
%if smooth = 1 smoothing before treating (diff and norm)

V = line.V;
iv = line.iv;
Vred = V(1:length(V)-1);

% correct for (I,V)=(0,0)
% find the smallest bias and set that to zero
if find(diff(sign(V)))
    [~,ind] = min(abs(V));
    ivcorr = NaN(size(iv));
    for k = 1:size(iv,2)
            ivcorr(:,k) = iv(:,k)-iv(ind,k);
    end
else
    ivcorr = iv;
end

%gaussian smooth bias over 10 data points
if smooth
    ivcorr = smoothdata(ivcorr, 1, 'gaussian', 10);
end


%differentiate and normalize data 
didv = NaN(length(Vred),size(iv,2));
norm_didv = NaN(length(Vred),size(iv,2));
for k = 1:size(iv,2)
    didv(:,k) = diff(ivcorr(:,k))./diff(V); % just didv not normalised
    normtemp = sqrt((ivcorr(1:length(Vred),k)./Vred).^2+C^2);
    norm_didv(:,k) = didv(:,k)./normtemp; % didv normalised
end

end
