%% Gridmap FFT (QPI)
qcenter = round(1+header.grid_dim(1)/2);
for k=1:size(Grid,3)
    qpi(:,:,k) = abs(fftshift(fft2(Grid(:,:,k))));
    qpi(qcenter,qcenter,k) = 0;
end

%% QPI from DataAnalysus 
QPI_used=LockinQPI;
for k=1:size(QPI_used,3) 
    qpi(:,:,k) = QPI_used(:,:,k);
end


%% Plot QPI
path=eval(['[''Gridmap_nos=',num2str(nos),'/QPI/'']']); %change your file name here 
mkdir(path);
load('InverseGray','invgray')

for k=1:size(qpi,3)
    figure(4)
    imagesc(qpi(:,:,k))
%    imadjust()
    hold on
    pbaspect([1 1 1])
    set(gcf,'Colormap',invgray) 
    xticks([])
    yticks([])
    eval(['fname = [''QPI'',num2str(k,''%03u''),''_(r,E='', num2str(1000*estart+(k-1)*egap), ''mV).png''];']) % File name with number label. You can change '-800+(k-1)*egap' part.
    F = getframe(gca);
    imwrite(F.cdata,[path,fname]); 
end