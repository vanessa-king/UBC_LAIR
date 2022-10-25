function [dIdV,ivcorr,Vred] = TreatIV(grd,C,sxy,sv)

extremesmooth = 25;

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

ivsextr = smooth3(ivcorr,'box',[extremesmooth,1,1]);

dIdV = NaN(length(Vred),size(iv,2),size(iv,3));

for kx = 1:size(iv,2)
    for ky = 1:size(iv,3)
        dIdVtemp = diff(ivcorr(:,kx,ky))./diff(V);
        normfactortemp = sqrt((ivsextr(1:length(V)-1,kx,ky)./Vred).^2+C^2);
        dIdV(:,kx,ky) = dIdVtemp./normfactortemp;
    end
end