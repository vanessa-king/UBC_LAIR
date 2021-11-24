function grd = gridLoadData(fld,stamp_project,img_nbr,grd_nbr, average_forward_and_backward)
% here Keyword: function; output argument: grd; function
% name:gridLoadData;input argument: fld, stamp_project,img_nbr,grd_nbr.
 

% file names
z_file = [stamp_project img_nbr '.Z_flat'];
iv_file = [stamp_project grd_nbr '.I(V)_flat']; % correctly load the data here

addpath(fld); % fld here = '.'; means...

fz = flat_parse(z_file); % This function parses a complete FLAT-File specified in "File" and returns its contents in a structure F. 
mz = flat2matrix(fz); %Transform FLAT data into a matrix
fiv = flat_parse(iv_file);
miv = flat2matrix(fiv);

rmpath(fld); %   Remove folder from search path.  

%---------------Treatment of image data-----------------------
% into nanometres
xraw = 1e9*mz{2}; % cell array : declared by using {}
yraw = 1e9*mz{3};

zraw = mz{1}; %why zraw doesn't need transform into nanometer here?  could it because it is energy level?

if find(abs(diff(sign(diff(xraw))))) % Check if image is scanned forwards and backwards
                                     % Only take the forward
                                     
    grd.x_img = xraw(1:length(xraw)/2); %the forward one, half of the length of xraw array, scanning along +x direction.
    ztmp = zraw(1:length(xraw)/2,:);  % taking all the 1:length(xraw)/2 colume of array in zraw to ztmp 
    
%   Or the other choice
%   grd.x_img = xraw((length(xraw)/2+1):end);   % the backward (length(xraw)/2+1):end
%   ztmp = zraw((length(xraw)/2+1):end,:);
    
else
    grd.x_img = xraw;
    ztmp = zraw;
end

if find(abs(diff(sign(diff(yraw))))) % Check if swept up and down
                                     % only take the up
  grd.y_img = yraw(1:length(yraw)/2);
  grd.z_img = ztmp(:,1:length(yraw)/2); %this is the upward
%     grd.y_img = yraw((length(yraw)/2+1):end); % this is the downward
%     grd.z_img = ztmp(:,(length(yraw)/2+1):end);
else
    grd.y_img = yraw;
    grd.z_img = ztmp;
end

% Plot images
% figure('Name','Topography'); % I want to show image as well.
% imagesc(grd.x_img,grd.y_img,grd.z_img');title('Z topography');xlabel('x / nm');ylabel('y / nm');axis image;axis xy;colorbar


%-----------Treatment of grid data----------------
% into nanometres
xraw = 1e9*miv{3};
yraw = 1e9*miv{4};
Vraw = miv{2};

ivraw = miv{1}; % mz 3-dimensional; miv 4-dimensional (another one dimension is energy)

if find(abs(diff(sign(diff(xraw))))) % Check to see if forward and backward
                                     % only take the forward
    grd.x = xraw(1:length(xraw)/2);
    ivtmp = ivraw(:,1:length(xraw)/2,:);     % this is the forward                                
%   grd.x = xraw(:,(length(xraw)/2+1):end); %this is the backward
%   ivtmp = ivraw(:,(length(xraw)/2+1):end,:);
else
    grd.x = xraw;
    ivtmp = ivraw;
end

if find(abs(diff(sign(diff(yraw))))) % Check to see if up and down
                                     % only take the up
  grd.y = yraw(1:length(yraw)/2);
  iv_dbl = ivtmp(:,:,1:length(yraw)/2);    % this is the upward                                 
%     grd.y = yraw((length(yraw)/2+1):end);  %this take the downward
%     iv_dbl = ivtmp(:,:,(length(yraw)/2+1):end); 
else
    grd.y = yraw;
    iv_dbl = ivtmp;
end

if find(abs(diff(sign(diff(Vraw))))) % Checks if V is swept forwards and backwards
                                     % averages forwards and backwards
    NV = length(Vraw)/2;
    grd.V = Vraw(1:NV);
    grd.iv = (iv_dbl(1:NV,:,:)+flip(iv_dbl(NV+1:2*NV,:,:),1))/2; 
    if (~average_forward_and_backward)
        grd.ivForward = iv_dbl(1:NV,:,:);
        grd.ivBackward = flip(iv_dbl(NV+1:2*NV,:,:),1);
else
    grd.V = Vraw;
    grd.iv = iv_dbl;
end

end
