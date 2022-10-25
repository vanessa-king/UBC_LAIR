%% Gaussian Filter on dI/dV spectra 
% If the gaussian filter is not needed, you can skip this paragraph.
% In this case, you should use dIdV rather than dIdVF for next paragraph

sg=30; %smaller sg, larger gaussian blur
x=reshape(label,elayer,1);
for i=1:xsize
for j=1:ysize
for k=1:elayer
    y(:,k) = gaussmf(x,[1/sg label(k)]);
    y(:,k) = y(:,k)/sum(y(:,k));
    dIdVF(i,j,k) = reshape(dIdV(i,j,:),1,elayer)*y(:,k);
end
end
end
%% Gridmap 
for k=1:elayer % dIdVF <-> dIdV
    Grid(:,:,k) = dIdV(:,:,k);
    MeddIdV(k) = median(median(dIdV(:,:,k)));
    Stdv(k) = std(std(dIdV(:,:,k)));
end
%% Gridmap print out (png files)
nos=15;
egap=20;
path=eval(['[''Gridmap_nos=',num2str(nos),'/Gridmap/'']']);

mkdir(path);

for k=1:elayer
    figure(3)
    imagesc(Grid(:,:,k))
    hold on
    pbaspect([1 1 1])
    set(gcf,'Colormap',bone) 
    caxis([MeddIdV(k)-nos*Stdv(k) MeddIdV(k)+nos*Stdv(k)]) % If you want to chance 2D-gridmap contrast you can change nos value
    xticks([])
    yticks([])
    eval(['fname = [''Gridmap'',num2str(k,''%03u''),''_(r,E='', num2str(-1000+(k-1)*egap), ''mV).png''];'])   % File name with number label. You can change '-800+(k-1)*egap' part.
    F = getframe(gca);
    imwrite(F.cdata,[path,fname]); 
end
