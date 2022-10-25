function line_didv = gridDrawLine(didv, Vred, imV, npoints)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[~,imN] = min(abs(Vred-imV));

didv_flip = flip(permute(didv,[1 3 2]),2); % flip didv so that image (x,y) = (0,0) at the bottom left

img = figure ('Name', ['Image of states at ',num2str(imV),' V']);imagesc(squeeze(didv_flip(imN,:,:)));colormap('gray');hold on
axis image

R = 2; %defining circles that will be drawn in image
xx = -R:.01:R;
yy = sqrt(R^2-xx.^2);

pos = zeros(2,2);
for k = 1:2
    figure(img)
    pos(:,k) = round(ginput(1)); %click the points to draw line between them
    plot(pos(1,k)+xx,pos(2,k)+yy,'r');
    plot(pos(1,k)+xx,pos(2,k)-yy,'r');
end
plot(pos(1,:),pos(2,:),'r','LineWidth',1) % draw the line

xpoints = round(pos(1,1):(pos(1,2) - pos(1,1))/(npoints-1):pos(1,2));
ypoints = round(pos(2,1):(pos(2,2) - pos(2,1))/(npoints-1):pos(2,2));
if isempty(xpoints)
    xpoints = ones(1,npoints)*pos(1,1);
elseif isempty(ypoints)
    ypoints = ones(1,npoints)*pos(2,1);
end

line_didv = zeros(length(Vred),npoints);
for i = 1:npoints
    line_didv(:,i) = didv_flip(:,ypoints(i),xpoints(i));
end

figure('Name', 'Spectra along line');
imagesc(1:npoints, Vred,line_didv); axis xy;







end

