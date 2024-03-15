function [mask, chosenPoints] = gridRectangularMask(data, cornerPoints)
    %improvement: chosenPoint to comment(output)
    
    arguments
    data    
    cornerPoints      {mustBeNumeric} =[]
    end

    % Check if data is a 2D map
    if ndims(data) ~= 2
        error('Data must be a 2D map');
    end

    [rows, cols] = size(data);

    % Display the data map and get corner points if not provided
    if nargin < 2 || isempty(cornerPoints)
        imagesc(data); % Display the data map
        colormap(gray);
        title('Click two opposite corners of the rectangle');
        [x, y] = ginput(2); % Get two points from the user
        cornerPoints = [x y];
    else
        if size(cornerPoints, 1) ~= 2 || size(cornerPoints, 2) ~= 2
            error('Corner points must be a 2x2 matrix');
        end
        x = cornerPoints(:, 1);
        y = cornerPoints(:, 2);
    end
    chosenPoints=zeros(2,2);
    chosenPoints(:,1)= x;
    chosenPoints(:,2)= y;

    % Ensure the coordinates are within the data bounds
    x = min(max(round(x), 1), cols);
    y = min(max(round(y), 1), rows);

    % Define the corners of the rectangle
    x1 = min(x);
    x2 = max(x);
    y1 = min(y);
    y2 = max(y);

    % Initialize the mask
    mask = false(rows, cols);

    % Fill in the rectangle in the mask
    mask(y1:y2, x1:x2) = true;
end
