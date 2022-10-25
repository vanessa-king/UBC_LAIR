%% Header load
[header, data, par] = load3ds('PtAs grid spec008.3ds',0);
xsize = header.grid_dim(1);
ysize = header.grid_dim(2);
elayer = header.points;
emax = par(1);
emin = par(2);
%% Data load
dfiles=dir('PtAs grid spec008.3ds');
nof2=length(dfiles);
for i=1:xsize
for j=1:ysize
    [header, data, par] = load3ds(dfiles.name,xsize*(i-1)+j-1);
    dIdV(i,j,:) = data(:,2);  % (x,y,energy) data: 1(I/V), 2(dI/dV)
    IV(i,j,:) = data(:,1);
end
end
%% Label
for i=1:elayer
    label(i) = sign(par(2))*(emin + (i-1)*(emax-emin)/(elayer-1));
end
data = [];
%% dI/dV Average
for k=1:elayer
    avg_dIdV(k) = mean(mean(dIdV(:,:,k))); % Here, 2 indicates dI/dV
    avg_IV(k) = mean(mean(IV(:,:,k))); % Here, 2 indicates dI/dV
end

figure(1)
plot(label,reshape(avg_dIdV(:),elayer,1))
figure(2)
plot(label,reshape(avg_IV(:),elayer,1))
%% Clearvars
clearvars -except elayer label avg_dIdV dIdV IV emax emin xsize ysize