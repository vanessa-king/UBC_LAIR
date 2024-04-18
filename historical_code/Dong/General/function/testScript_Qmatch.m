%% random test data

img = rand(50)*255; %size of image


%% load real data

img = imread('Picture2.png');
img = im2gray(img);

%crop edge
cropPixel = 5; %cuts edge
img = img(cropPixel+1:end-cropPixel,cropPixel+1:end-cropPixel);


%disp img
figure(1)
imshow(img)

%% set q-vector an threshold

drow = 25; %offset in row of q-vector
dcol = 30; %offset in col of q-vector
thresholdVal = 0.20*255; % threshold for start and end pixel of q-vector



%% test imageprocessing

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
hold on

plotBool = 1;
%plot 'q-vectors'
if plotBool == 1
    for n=1:length(lineCoords)
        if lineCoords(n,2)+dcol == lineCoords(n,4) && lineCoords(n,1)+drow == lineCoords(n,3)
            %full match withing the primary zone image
            line([lineCoords(n,2),lineCoords(n,4)],[lineCoords(n,1),lineCoords(n,3)],'color',[0.4660 0.6740 0.1880], 'linewidth', 1.5)
        elseif lineCoords(n,2)+dcol == lineCoords(n,4)
            %col withing the primary zone image
            line([lineCoords(n,2),lineCoords(n,4)],[lineCoords(n,1),lineCoords(n,3)],'color',[0.8500 0.3250 0.0980], 'linewidth', 1, 'linestyle', '--')
        elseif lineCoords(n,1)+drow == lineCoords(n,3)
            %row withing the primary zone image
            line([lineCoords(n,2),lineCoords(n,4)],[lineCoords(n,1),lineCoords(n,3)],'color',[0.9290 0.6940 0.1250], 'linewidth', 1, 'linestyle', '--')
        else
            line([lineCoords(n,2),lineCoords(n,4)],[lineCoords(n,1),lineCoords(n,3)],'color',[0.6350 0.0780 0.1840], 'linewidth', 1, 'linestyle', '--')
        end
    end
end
hold off