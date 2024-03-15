% Test script for gridRectangularMask and gridCropmask
%% Mask the data with rectangulr mask
data = rand(100); % Example 2D data map
%cornerPoints = [20, 30; 80, 70]; % Specify corner points as [x1, y1; x2, y2]
[mask, chosenPoints] = gridRectangularMask(data);

figure; 
imshow(data, []); % Show the data map
hold on;
h = imshow(mask); % Show the mask
set(h, 'AlphaData', 0.3); % Make the mask semi-transparent
title('Data with Rectangular Mask Overlay');

%% crop the data 
figure;
cropped_data= gridCropmask(data, mask);
imshow(cropped_data);
