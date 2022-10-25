%% Gridmap FFT (QPI)
qcenter = round(1+xsize/2);
for k=1:elayer
    qpi(:,:,k) = abs(fftshift(fft2(Grid(:,:,k))));
    qpi(qcenter,qcenter,k) = 0;
end
%% Plot QPI
path=eval(['[''Gridmap_nos=',num2str(nos),'/QPI/'']']);
mkdir(path);
load('InverseGray','invgray')

for k=1:elayer
    figure(4)
    imagesc(qpi(:,:,k))
    hold on
    pbaspect([1 1 1])
    set(gcf,'Colormap',invgray) 
    xticks([])
    yticks([])
    eval(['fname = [''QPI'',num2str(k,''%03u''),''_(r,E='', num2str(-400+(k-1)*egap), ''mV).png''];']) % File name with number label. You can change '-800+(k-1)*egap' part.
    F = getframe(gca);
    imwrite(F.cdata,[path,fname]); 
end
