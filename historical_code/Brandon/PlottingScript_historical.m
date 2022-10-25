%% Plot dIdV

i = 100;
% for i = 1:200
    close
    fig = figure('Position',[50 50 512 512]);
    hold on
        h = imagesc(dIdV_nostreaks(:,:,i),[0.1*min(min(dIdV_nostreaks(:,:,i))) 0.075*max(max(dIdV_nostreaks(:,:,i)))]);
        axis equal
        set(0,'defaultaxesposition',[0 0 1 1]); % Sets the position of the axis
        colormap(cm_inferno);
        pbaspect([1 1 1])
        axis off
    hold off

%     savename = strcat(num2str(midV(i)),'.png');
%     Image = getframe(gcf);
%     imwrite(Image.cdata, savename);
% end

%% Plot QPI

i = 100;
% for i = 1:200
    close
    fig = figure('Position',[50 50 512 512]);
    hold on
        h = imagesc(QPI_symm_crop(:,:,i),[0.1*min(min(QPI_symm_crop(:,:,i))) 0.075*max(max(QPI_symm_crop(:,:,i)))]);
        axis equal
        set(0,'defaultaxesposition',[0 0 1 1]); % Sets the position of the axis
        colormap(flipud(cm_magma));
        pbaspect([1 1 1])
        axis off
    hold off

%     savename = strcat(num2str(midV(i)),'.png');
%     Image = getframe(gcf);
%     imwrite(Image.cdata, savename);
% end
