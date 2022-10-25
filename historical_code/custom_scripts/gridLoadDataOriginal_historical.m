function grd = gridLoadData(fld,stamp_project,img_nbr,grd_nbr)

% file names
z_file = [stamp_project img_nbr '.Z_flat'];
iv_file = [stamp_project grd_nbr '.I(V)_flat'];

addpath(fld);

fz = flat_parse(z_file);
mz = flat2matrix(fz);
fiv = flat_parse(iv_file);
miv = flat2matrix(fiv);

rmpath(fld);

%---------------Treatment of image data-------------
% into nanometres
xraw = 1e9*mz{2};
yraw = 1e9*mz{3};

zraw = mz{1};

if find(abs(diff(sign(diff(xraw))))) % Check if image is scanned forwards and backwards
                                     % only take the forward
    grd.x_img = xraw(1:length(xraw)/2);   % The forward one
    ztmp = zraw(1:length(xraw)/2,:);
else
    grd.x_img = xraw;
    ztmp = zraw;
end

if find(abs(diff(sign(diff(yraw))))) % Check if swept up and down
                                     % only take the up
    grd.y_img = yraw(1:length(yraw)/2);
    grd.z_img = ztmp(:,1:length(yraw)/2);
else
    grd.y_img = yraw;
    grd.z_img = ztmp;
end

%Plot images
% figure('Name','Topography');
% imagesc(grd.x_img,grd.y_img,grd.z_img');title('Z topography');xlabel('x / nm');ylabel('y / nm');axis image;axis xy;colorbar

%-----------Treatment of grid data----------------
% into nanometres
xraw = 1e9*miv{3};
yraw = 1e9*miv{4};
Vraw = miv{2};

ivraw = miv{1};

if find(abs(diff(sign(diff(xraw))))) % Check to see if forward and backward
                                     % only take the forward
    grd.x = xraw(:,1:length(xraw)/2);
    ivtmp = ivraw(:,1:length(xraw)/2,:);
else
    grd.x = xraw;
    ivtmp = ivraw;
end

if find(abs(diff(sign(diff(yraw))))) % Check to see if up and down
                                     % only take the up
    grd.y = yraw(1:length(yraw)/2);
    iv_dbl = ivtmp(:,:,1:length(yraw)/2);
else
    grd.y = yraw;
    iv_dbl = ivtmp;
end

if find(abs(diff(sign(diff(Vraw))))) % Checks if V is swept forwards and backwards
                                     % averages forwards and backwards
    NV = length(Vraw)/2;
    grd.V = Vraw(1:NV);
    grd.iv = (iv_dbl(1:NV,:,:)+flip(iv_dbl(NV+1:2*NV,:,:),1))/2; 
else
    grd.V = Vraw;
    grd.iv = iv_dbl;
end

end