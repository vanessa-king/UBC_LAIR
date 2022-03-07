function grd = gridLoadData(fld,stamp_project,img_number,grd_number)

% file names
Z_file = [stamp_project img_number '.Z_flat'];
I_file = [stamp_project grd_number '.I(V)_flat'];

addpath(fld);

fZ = flat_parse(Z_file);
mZ = flat2matrix(fZ);
fI = flat_parse(I_file);
mI = flat2matrix(fI);

rmpath(fld);

%---------------Treatment of image data-------------
% into nanometres
xraw = 1e9*mZ{2};
yraw = 1e9*mZ{3};

zraw = mZ{1};

if find(abs(diff(sign(diff(xraw))))) % Check if image is scanned forwards and backwards
                                     % only take the forward
    grd.x_img = xraw(1:length(xraw)/2); %the forward one.
%   grd.x_img = xraw((length(xraw)/2+1):end);   % the backward (length(xraw)/2+1):end
%   ztmp = zraw((length(xraw)/2+1):end,:);
    ztmp = zraw(1:length(xraw)/2,:);
else
    grd.x_img = xraw;
    ztmp = zraw;
end

if find(abs(diff(sign(diff(yraw))))) % Check if swept up and down
                                     % only take the up
%   grd.y_img = yraw(1:length(yraw)/2);
%   grd.z_img = ztmp(:,1:length(yraw)/2); %this is the upward
    grd.y_img = yraw((length(yraw)/2+1):end); % now is the downward
    grd.z_img = ztmp(:,(length(yraw)/2+1):end);
else
    grd.y_img = yraw;
    grd.z_img = ztmp;
end

%Plot images
% figure('Name','Topography');
% imagesc(grd.x_img,grd.y_img,grd.z_img');title('Z topography');xlabel('x / nm');ylabel('y / nm');axis image;axis xy;colorbar

%-----------Treatment of grid data----------------
% into nanometres
xraw = 1e9*mI{3};
yraw = 1e9*mI{4};
Vraw = mI{2};

Iraw = mI{1};

if find(abs(diff(sign(diff(xraw))))) % Check to see if forward and backward
                                     % only take the forward
    grd.x = xraw(:,1:length(xraw)/2);
    Itmp = Iraw(:,1:length(xraw)/2,:);     % this is the forward                                
%   grd.x = xraw(:,(length(xraw)/2+1):end); %this is the backward
%   Itmp = Iraw(:,(length(xraw)/2+1):end,:);
else
    grd.x = xraw;
    Itmp = Iraw;
end

if find(abs(diff(sign(diff(yraw))))) % Check to see if up and down
                                     % only take the up
%   grd.y = yraw(1:length(yraw)/2);
%   I_dbl = Itmp(:,:,1:length(yraw)/2);    % this is the upward                                 
    grd.y = yraw((length(yraw)/2+1):end);  %then take the downward
    I_dbl = Itmp(:,:,(length(yraw)/2+1):end); 
else
    grd.y = yraw;
    I_dbl = Itmp;
end

if find(abs(diff(sign(diff(Vraw))))) % Checks if V is swept forwards and backwards
                                     % averages forwards and backwards
    NV = length(Vraw)/2;
    grd.V = Vraw(1:NV);
    grd.I = (I_dbl(1:NV,:,:)+flip(I_dbl(NV+1:2*NV,:,:),1))/2; 
else
    grd.V = Vraw;
    grd.I = I_dbl;
end

end
