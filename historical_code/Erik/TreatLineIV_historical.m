function [dIdV,ivcorr,Vred] = TreatLineIV(data,C,sx,sv)

extremesmooth = 25;

V = data.V;
iv = data.iv;
Vred = V(1:length(V)-1);

ivs = NaN(size(iv));

for k = 1:size(iv,2)
    ivs(:,k) = smooth(iv(:,k),sv);
end

for k = 1:size(iv,1)
    ivs(k,:) = smooth(ivs(k,:),sx);
end

if find(diff(sign(V)))
    [~,ind] = min(abs(V));
    ivcorr = NaN(size(iv));
    for k = 1:size(iv,2)
            ivcorr(:,k) = ivs(:,k)-ivs(ind,k);
    end
else
    ivcorr = iv;
end

ivsextr = NaN(size(iv));

for k = 1:size(iv,2)
    ivsextr(:,k) = smooth(ivcorr(:,k),extremesmooth);
end

dIdV = NaN(length(Vred),size(iv,2));

for k = 1:size(iv,2)
    dIdVtemp = diff(ivcorr(:,k))./diff(V);
    normfactortemp = sqrt((ivsextr(1:length(V)-1,k)./Vred).^2+C^2);
    dIdV(:,k) = dIdVtemp./normfactortemp;
end