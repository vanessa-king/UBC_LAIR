%% Gridmap from Lockin signal 
LockindIdV_used= LockindIdV;
for k=1:elayer 
    Grid(:,:,k) = LockindIdV_used(:,:,k);
    MeddIdV(k) = median(median(LockindIdV_used(:,:,k)));
    Stdv(k) = std(std(LockindIdV_used(:,:,k)));
end
%% Gridmap from dIdV signal 
dIdV_used= dIdV;
for k=1:elayer-1 
    Grid(:,:,k) = dIdV_used(:,:,k);
    MeddIdV(k) = median(median(dIdV_used(:,:,k)));
    Stdv(k) = std(std(dIdV_used(:,:,k)));
end
%% Gridmap print out (png files)
nos=10;
egap=1000*(eend-estart)/elayer;
path=eval(['[''Gridmap_nos=',num2str(nos),'/Gridmap/'']']); %change your file path here

mkdir(path);

for k=1:size(Grid,3)
    figure(3)
    imagesc((Grid(:,:,k)))
    hold on
    pbaspect([1 1 1])
    set(gcf,'Colormap',bone)
    caxis([MeddIdV(k)-nos*Stdv(k) MeddIdV(k)+nos*Stdv(k)]) % If you want to change 2D-gridmap contrast you can change nos value
    xticks([])
    yticks([])
    eval(['fname = [''Gridmap'',num2str(k,''%03u''),''_(r,E='', num2str(1000*estart+(k-1)*egap), ''mV).png''];'])   % File name with number label. You can change '-800+(k-1)*egap' part.
    F = getframe(gca);
    imwrite(F.cdata,[path,fname]); 
end