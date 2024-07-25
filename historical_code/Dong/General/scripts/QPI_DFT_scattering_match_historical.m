%% Description: This script is used to make matches between the vectors in QPI and the band scattering in the DFT calculations. 

%% load real data
P1='qpi.png';
P2='DFT.png';
img1 = imread(P1);
img2 = imread(P2);
I1 = 255-im2gray(img1);
I2 = 255-im2gray(img2);

length_ratio=2;

%crop edge
cropPixel = 5; %cuts edge
I2 = I2(cropPixel+1:end-cropPixel,cropPixel+1:end-cropPixel);

I2 = rot90(I2);

%disp img
figure(1)
imshow(I2)

%% JDOS plot 
% self convolution of DFT calculation 

convoluted_img = conv2(double(I2), double(I2));
%convoluted_img = log(convoluted_img);
minval=min(convoluted_img(:));
maxval=max(convoluted_img(:));
scaled_img=(convoluted_img-minval)/(maxval-minval)*255;
% scale the intensity of the Jdos 
%Jdos=log(Jdos);

%disp jdos
figure(2)
imshow(uint8(scaled_img))
%% Determine q-vector 
img_findlocalmax = imginvgrey(P1);
[Max,row_max,col_max]=findlocalmax(img_findlocalmax);

row_avg=round(mean(row_max));
col_avg=round(mean(col_max));

% scaling 

scaling_ratio=lengthscaling(I1,I2,length_ratio);

%% Make line mask across the target q-vector and the center of QPI

topo=im2double(I1);
pointA=[col_avg,row_avg];
pointB=[round(size(topo,1)/2),round(size(topo,2)/2)];
[mask, comment] = gridMaskLine(topo,pointA,pointB);

%% Show mask created 
imshow(mask)

%% set q-vector an threshold

drow=round((size(I1,1)/2-row_avg)*scaling_ratio);  %offset in row of q-vector
dcol=round((size(I1,2)/2-col_avg)*scaling_ratio);  %offset in col of q-vector
thresholdVal = 0.68*255; % threshold for start and end pixel of q-vector



%% test imageprocessing
img=I2;

figure(2)
p1 = image(img,'CDataMapping','scaled');
colorbar
axis square;

[mapT, mapQ, lineCoords] = qMatchMap(img,drow,dcol,thresholdVal);


figure(3)
p2 = image(mapT,'CDataMapping','scaled');
colorbar
axis square;

figure(4)
p3 = image(mapQ,'CDataMapping','scaled');
colorbar
axis square;

if ~isempty(lineCoords)
    % make a (1+row_jump) x (1+col_jump) enlarged image
    imgExtended = repmat(img, (1+max(lineCoords(:,5))), (1+max(lineCoords(:,6))) );

    %larger plot of tiles image
    figure(5)
    p4 = image(imgExtended,'CDataMapping','scaled');
    colorbar
    pbaspect([(1+max(lineCoords(:,6))), (1+max(lineCoords(:,5))), 1]);

    plotBool = 1;
    %plot 'q-vectors'
    if plotBool == 1
        for n=1:length(lineCoords)
            if lineCoords(n,2)+dcol == lineCoords(n,4) && lineCoords(n,1)+drow == lineCoords(n,3)
                %full match withing the primary zone image
                line([lineCoords(n,2),lineCoords(n,4)],[lineCoords(n,1),lineCoords(n,3)],'color',[0.4660 0.6740 0.1880], 'linewidth', 1)
            elseif lineCoords(n,2)+dcol == lineCoords(n,4)
                %col withing the primary zone image
                %line([lineCoords(n,2),lineCoords(n,4)],[lineCoords(n,1),lineCoords(n,3)+(size(img,1)*lineCoords(n,5))],'color',[0.8500 0.3250 0.0980], 'linewidth', 1, 'linestyle', '--')
            elseif lineCoords(n,1)+drow == lineCoords(n,3)
                %row withing the primary zone image
               % line([lineCoords(n,2),lineCoords(n,4)+(size(img,2)*lineCoords(n,6))],[lineCoords(n,1),lineCoords(n,3)],'color',[0.9290 0.6940 0.1250], 'linewidth', 1, 'linestyle', '--')
            else
                %line([lineCoords(n,2),lineCoords(n,4)+(size(img,2)*lineCoords(n,6))],[lineCoords(n,1),lineCoords(n,3)+(size(img,1)*lineCoords(n,5))],'color',[0.6350 0.0780 0.1840], 'linewidth', 1, 'linestyle', '--')
            end
        end
    end
else
    disp('No matching q-vectors to display')
end 
