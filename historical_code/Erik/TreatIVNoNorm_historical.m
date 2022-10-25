function [dIdV,ivcorr,Vred] = TreatIVNoNorm(grd,sxy,sv)

V = grd.V;
iv = grd.iv;
Vred = V(1:length(V)-1);

ivs = smooth3(iv,'box',[sv,sxy,sxy]);

if find(diff(sign(V)))
    [~,ind] = min(abs(V));
    ivcorr = NaN(size(iv));
    for kx = 1:size(iv,2)
        for ky = 1:size(iv,3)
            ivcorr(:,kx,ky) = ivs(:,kx,ky)-ivs(ind,kx,ky);
        end
    end
else
    ivcorr = ivs;
end

dIdV = NaN(length(Vred),size(iv,2),size(iv,3));

for kx = 1:size(iv,2)
    for ky = 1:size(iv,3)
        dIdVtemp = diff(ivcorr(:,kx,ky))./diff(V);
        dIdV(:,kx,ky) = dIdVtemp;
    end
end