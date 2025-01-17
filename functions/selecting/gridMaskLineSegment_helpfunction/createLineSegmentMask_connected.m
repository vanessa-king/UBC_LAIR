function [mask] = createLineSegmentMask_connected(imageSize, startPoint, endPoint)
    mask = zeros(imageSize);
    
    % Round points to nearest integer
    x1 = round(startPoint(1));
    y1 = round(startPoint(2));
    x2 = round(endPoint(1));
    y2 = round(endPoint(2));
    
    % Calculate differences and steps
    dx = abs(x2 - x1);
    dy = abs(y2 - y1);
    
    % Store previous point
    prevX = x1;
    prevY = y1;
    
    % Set initial point
    mask(x1, y1) = 1;
    
    % Determine primary direction
    if dx > dy
        % Horizontal-dominant line
        xStep = sign(x2 - x1);
        x = x1;
        y = y1;
        
        % Calculate slope
        slope = (y2 - y1) / (x2 - x1);
        
        while x ~= x2
            x = x + xStep;
            y = y1 + slope * (x - x1);
            newY = round(y);
            
            % Check if new point shares a side with previous point
            if ~(x == prevX || newY == prevY)
                % Add intermediate point (Ax = Q1x, Ay = Q2y)
                mask(prevX, newY) = 1;
            end
            
            % Set current point
            if x >= 1 && x <= imageSize(1) && newY >= 1 && newY <= imageSize(2)
                mask(x, newY) = 1;
            end
            
            % Update previous point
            prevX = x;
            prevY = newY;
        end
    else
        % Vertical-dominant line
        yStep = sign(y2 - y1);
        x = x1;
        y = y1;
        
        % Calculate inverse slope
        slope = (x2 - x1) / (y2 - y1);
        
        while y ~= y2
            y = y + yStep;
            x = x1 + slope * (y - y1);
            newX = round(x);
            
            % Check if new point shares a side with previous point
            if ~(newX == prevX || y == prevY)
                % Add intermediate point (Ax = Q2x, Ay = Q1y)
                mask(newX, prevY) = 1;
            end
            
            % Set current point
            if newX >= 1 && newX <= imageSize(1) && y >= 1 && y <= imageSize(2)
                mask(newX, y) = 1;
            end
            
            % Update previous point
            prevX = newX;
            prevY = y;
        end
    end
    
    mask = logical(mask);
end
