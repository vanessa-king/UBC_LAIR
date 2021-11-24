%% Header loading
[header, data, par] = load3ds('Grid Spectroscopy010.3ds',0);  % Type your grid file name here
Rxsize=15;
Rysize=15;  %Type your spatial dimension of the grid 
xsize = header.grid_dim(1);
ysize = header.grid_dim(2);
elayer = header.points;
estart = par(1);
eend = par(2);
%% Data loading
dfiles=dir('*.3ds');
nof2=length(dfiles); 
for i=1:xsize
for j=1:ysize
    [header, data1, par1] = load3ds('Grid Spectroscopy010.3ds',xsize*(i-1)+(j-1)); % Type your grid file name here
    dIdV(i,j,:,1) = data1(:,3);
    IV(i,j,:,1) = data1(:,1);
end
end 
%% Label
if estart > eend
    emax=estart;
    emin=eend;
else
    emax=eend;
    emin=estart;
end
for i=1:elayer
    label(i) = sign(par(2))*(emin + (i-1)*(emax-emin)/(elayer-1));
end

%% Average spectrum
for k=1:elayer
    avgIV(k)= mean(mean(IV(:,:,k)));
    avgdIdV(k)= mean(mean(dIdV(:,:,k)));
end

figure(1)
plot(label,avgIV)

figure(2)
plot(label,avgdIdV)

%% Anomaly map 
tempdIdV=zeros(1,elayer);
anomalymap=zeros(xsize,ysize);
for i = 1:xsize
    for j = 1:ysize
        tempdIdV(1,:)=dIdV(i,j,:);
        anomalymap(i,j)=goodnessOfFit(tempdIdV,avgdIdV,"MSE");
    end 
end
figure(3)
contour(anomalymap)
%mesh(anomalymap)
%% Clear parameters
clear i j k l data data1 data2 par par1 par2 dfiles nof2 sg estart eend;