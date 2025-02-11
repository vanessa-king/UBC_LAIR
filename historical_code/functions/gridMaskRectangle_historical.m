function [mask, num_in_mask, comment] = gridMaskRectangle_historical(data, cornerPoints)
% This function create a rectangular mask 
% Given 2 points, this function creates a rectangular mask in the area defined by the 2 points.   

% mask: Rectangular mask produced 
% num_in_mask: number of total points in the mask
    
    arguments
    data    
    cornerPoints {mustBeNumeric} = []
    end 
    
    % Load colour maps
    color_scale_resolution = 1000; % 1000 evenly spaced colour points
    cm_magma = magma(color_scale_resolution);
    
    % Check if data is a 2D map
    if ndims(data) ~= 2
        error('Data must be a 2D map');
    end

    [rows, cols] = size(data);

    % Display the data map and get corner points if not provided
    if nargin < 2 || isempty(cornerPoints)
        imagesc(data); % Display the data map
        axis xy
        colormap(cm_magma);
        title('Click two opposite corners of the rectangle');
        cornerPoints = ginputAllPlatform(2); % Get two points from the user
    else
        if size(cornerPoints, 1) ~= 2 || size(cornerPoints, 2) ~= 2
            error('Corner points must be a 2x2 matrix');
        end
    end
    
    % Round points from ginputALLplatform or manual input
    cornerPoints = round(cornerPoints);
    
    % Check if the provided corner points are within the data bounds
    if any(cornerPoints(:,1) < 1 | cornerPoints(:,1) > cols | ...
           cornerPoints(:,2) < 1 | cornerPoints(:,2) > rows)
        error('Corner points must be within the dimensions of the data');
    end

    x = cornerPoints(:, 1);
    y = cornerPoints(:, 2);

    % Define the corners of the rectangle
    x1 = min(x);
    x2 = max(x);
    y1 = min(y);
    y2 = max(y);

    % Initialize the mask
    mask = false(rows, cols);

    % Fill in the rectangle in the mask
    mask(y1:y2, x1:x2) = true;

    % Count the number of points in the mask
    num_in_mask = sum(mask(:));

    % Format the chosen points for inclusion in the comment
    chosenPointsStr = sprintf('[%.2f, %.2f; %.2f, %.2f]', cornerPoints(1,1), cornerPoints(1,2), cornerPoints(2,1), cornerPoints(2,2));

    % Generate the comment, referring to 'data' generically
    comment = sprintf('gridMaskRectangle called with data of size [%d, %d] and corner points %s.', size(data, 1), size(data, 2), chosenPointsStr);
end

