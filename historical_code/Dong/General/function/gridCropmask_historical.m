function [Cropped_data] = gridCropmask(data, mask)
    % Validate inputs
    arguments
        data    
        mask logical
    end

    % Find indices of true elements in the mask
    [row, col] = find(mask);

    % Determine the start and end points of the rectangle
    x_start = min(row);
    x_end = max(row);
    y_start = min(col);
    y_end = max(col);

    % Check if the mask forms a perfect rectangle
    isRectangular = true;
    check_mask=zeros(size(mask));
    check_mask(x_start:x_end, y_start:y_end)=1;
    
    if sum(check_mask-mask, "all") ~= 0
       isRectangular = false;
    end

    % Return the cropped data if the mask is rectangular, otherwise issue a warning
    if isRectangular
        Cropped_data = data(x_start:x_end, y_start:y_end);
    else
        error('Please use a rectangular mask.');
    end
end
