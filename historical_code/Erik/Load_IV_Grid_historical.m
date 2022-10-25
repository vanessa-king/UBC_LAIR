function GRD = Load_IV_Grid_Erik

fld = 'C:\Users\acqu\Documents\DATA\LT graphene data\2018-06-04\flat';
stamp_project = '20180604-092422_Graphene_SiC--';
img_nbr = '43_1';
grd_nbr = '45_1';

z_file = [stamp_project img_nbr '.Z_flat'];
iv_file = [stamp_project grd_nbr '.I(V)_flat'];

addpath(fld);

fz = flat_parse(z_file);
mz = flat2matrix(fz);
fiv = flat_parse(iv_file);
miv = flat2matrix(fiv);

rmpath(fld);

%---------------Treatment of image data-------------
xraw = 1e9*mz{2};
yraw = 1e9*mz{3};

zraw = mz{1};

if find(abs(diff(sign(diff(xraw))))) %Check if image is scanned forwards and backwards
    GRD.x_img = xraw(1:length(xraw)/2);
    ztmp = zraw(1:length(xraw)/2,:);
else
    GRD.x_img = xraw;
    ztmp = zraw;
end

if find(abs(diff(sign(diff(yraw))))) %Check if swept up and down
    GRD.y_img = yraw(1:length(yraw)/2);
    GRD.z_img = ztmp(:,1:length(yraw)/2);
else
    GRD.y_img = yraw;
    GRD.z_img = ztmp;
end

%Plot images
figure('Name','Topography');
imagesc(GRD.x_img,GRD.y_img,GRD.z_img');title('Z topography');xlabel('x / nm');ylabel('y / nm');axis image;axis xy;colorbar

%-----------Treatment of grid data----------------
xraw = 1e9*miv{3};
yraw = 1e9*miv{4};
Vraw = miv{2};

ivraw = miv{1};

if find(abs(diff(sign(diff(xraw)))))
    GRD.x = xraw(:,1:length(xraw)/2);
    ivtmp = ivraw(:,1:length(xraw)/2,:);
else
    GRD.x = xraw;
    ivtmp = ivraw;
end

if find(abs(diff(sign(diff(yraw)))))
    GRD.y = yraw(1:length(yraw)/2);
    iv_dbl = ivtmp(:,:,1:length(yraw)/2);
else
    GRD.y = yraw;
    iv_dbl = ivtmp;
end

if find(abs(diff(sign(diff(Vraw))))) %checks if V is swept forwards and backwards
    NV = length(Vraw)/2;
    GRD.V = Vraw(1:NV);
    GRD.ivf = iv_dbl(1:NV,:,:);
    GRD.ivb = iv_dbl(NV+1:2*NV,:,:);
    GRD.iv = (iv_dbl(1:NV,:,:)+flip(iv_dbl(NV+1:2*NV,:,:),1))/2;
else
    NV = length(Vraw);
    GRD.V = Vraw;
    GRD.iv = iv_dbl;
end

end