function [] =realspacemap(endpoint)


%--for real space grid map----
% eint=1;
% for k=1:200/eint
% %     energy = -202+2*k;
for k=1:endpoint
    const=50; % constant number for caxis contrast.
    energy = -202+2*k;
%     figure(13)
    t = sprintf(  'k = %d, Energy: %d mV',k,energy);
    figure(13)
    imagesc(rot90(norm_didv2(:,:,k))) %plot 2D image
    
    hold on
    pbaspect([1 1 1]) %image size ratio [x,y,1]
    set(gcf, 'Colormap', gray)
    xticks([])
    yticks([])
     title(t)
   caxis([min(min(norm_didv2(:,:,k))) 2*max(max(norm_didv2(:,:,k)))])
    caxis([Med(k)-const*sg(k) Med(k)+const*sg(k)])
    
    
    name = sprintf('./realimagedata/k_%d.jpg',k);    %name of the figure
    saveas(13,name)  %save figure 13 as name
% eval([fname = [''Norm_dIdV'',num2str(k,''%03u''),''_(r,E='', num2str(-200+(k-1)*2) mV).png''];'])      
   % F = getframe(gca);
 %   imwrite(F.cdata,['output2/grid_NbIrTe4_Tmovie_',stamp_project,'dI(V)_',num2str(iv_nbr),'.png']])
end