function [mask] = imgMaskdraw(img)
%This function create a mask based on the elipse that the user draw

% Load an image and plot the original image

    figure, imshow(img), title('Original Image');

% Create a figure and set up the callback

    hFig = figure('name', 'Draw a Circle on the Image', 'NumberTitle', 'off');
    hAx = axes('Parent', hFig);
    imshow(img, 'Parent', hAx);
    hEllipse = imellipse(hAx);
    setPositionConstraintFcn(hEllipse, @(pos) constrainToImage(pos, hAx));

% Wait for the user to double-click

    addNewPositionCallback(hEllipse, @(p) title('Double-click inside the circle when done'));
    wait(hEllipse);

% Create the mask

    mask = createMask(hEllipse);
    figure, imshow(mask), title('Mask');

% Function to constrain the ellipse to the axes limits
    
    function pos = constrainToImage(pos, hAx)
        % Adjust the position vector to keep the ellipse inside the axes
        xLim = get(hAx, 'XLim');
        yLim = get(hAx, 'YLim');
        pos(1) = max(xLim(1), min(pos(1), xLim(2) - pos(3)));
        pos(2) = max(yLim(1), min(pos(2), yLim(2) - pos(4)));
    end

end
