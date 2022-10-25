%% header open
[header_IV, data_dIdV, par] = load3ds('Grid Spectroscopy006.3ds',0);
xsize = header_IV.grid_dim(1);
ysize = header_IV.grid_dim(2);
elayer = header_IV.points;
emin = min(par(1),par(2));
emax = max(par(1),par(2));
for i=1:elayer
    label(i) = emin + (i-1)*(emax-emin)/(elayer-1);
end
%% 3ds open
for i=1:xsize
        [header_IV, data_dIdV, par] = load3ds('Grid Spectroscopy006.3ds',i-1);
        dIdV(i,:) = data_dIdV(:,2);
end
%% Waterfall plot
figure;
for i=1:xsize
    pbaspect([0.7,1,1])
    plot(label, 0.02*(i-1)*10^-11 + reshape(dIdV(i,:),elayer,1),'color',[0.3 0.3 0.3])
    axis([-0.4 0.4 0 2.8*10^-11])
    hold on
    title('dI/dV (Water Fall)')
    xlabel('Bias Voltage [V]')
    ylabel('dI/dV [a.u.]')
end
%% Copy
mindidv= min(min(dIdV));
maxdidv= max(max(dIdV));
m = size(dIdV,1);
offset = 0.2;

figure;
for i=m:-1:1
    if i < m
    X=[label, fliplr(label)]';
%     Z=[dIdV(m+1-i,:) zeros(size(dIdV(m+1-i,:)))]+(m+1-i)*offset*10^-12;  % 그래프 아래쪽 다 칠하기
    Z=[dIdV(i,:)+(i-1)*offset*10^-12 flipud(fliplr(dIdV(i+1,:)))+i*offset*10^-12];  % GOOD!
   
    Hpatch=fill(X, Z,'b');
    cdata=get(Hpatch,'ydata');%+(i)*offset*10^-12;
    cdata=(cdata-min(mindidv+i*offset*10^-12))/(max(maxdidv+i*offset*10^-12)-min(mindidv+i*offset*10^-12)); %// normalise
    set(Hpatch,'CData',cdata,'FaceColor','interp')
    
    hold on
    colormap magma
    colorbar
    caxis([-0.4 1])
    axis([-0.4 0.4 0 2.8*10^-11])
    pbaspect([0.7 1 1])
    title('dI/dV (Water Fall)')
    xlabel('Bias Voltage [V]')
    ylabel('dI/dV [a.u.]')
    grid on;
end
end
hold off;