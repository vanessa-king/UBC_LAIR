function [masks, comment] = gridDirectionalMask(data)
%Average grid along a given direction with interactive width selection
%
% Arguments:
%   data        2D or 3D array containing the data.
%
% Returns:
%   masks       3D array of logical masks (data_dim x data_dim x L)
%   comment     Comment for logging the function call.
%
% August 2024 - Dong Chen
% Nov. 2024 - Dong Chen

% Get the main line L using gridMaskLineSegment
[mainMask, mainComment, startPoint, endPoint, polcoord] = gridMaskLineSegment(data);

if isempty(startPoint) || isempty(endPoint)
    error('Line selection was cancelled or invalid');
end

% Find all points along the main line
[linePoints_y, linePoints_x] = find(mainMask);
linePoints = [linePoints_x, linePoints_y];  % convert to [x,y]
lineLength = length(linePoints_x);

% Calculate perpendicular angle in degrees
perpAngle = deg2rad(polcoord(2)) + pi/2;  % Convert degrees to radians and add 90 degrees

% Initialize width
width = 10;

% Create interactive rectangle for width selection
figure('WindowButtonMotionFcn', @updateRectangle);
image(data, 'CDataMapping', 'scaled');
axis square
hold on

% Draw original line
line([startPoint(1), endPoint(1)], [startPoint(2), endPoint(2)], ...
    'Color', 'red', 'LineWidth', 1.5);

% Initialize state variables
isDragging = false;
rectHandle = [];
dragHandles = [];

% Create initial visualization
updateRectangle();
createDragHandles();

% Add button for confirmation
uicontrol('Style', 'pushbutton', 'String', 'Confirm Width', ...
    'Position', [10 10 100 30], ...
    'Callback', @confirmWidth);

% Set figure callbacks for dragging
set(gcf, 'WindowButtonDownFcn', @startDragging);
set(gcf, 'WindowButtonUpFcn', @stopDragging);
set(gcf, 'WindowButtonMotionFcn', @updateDragging);

% Wait for user confirmation
uiwait(gcf);

% Initialize 3D mask array
masks = false(size(data,1), size(data,2), lineLength);

% Generate perpendicular line masks
for i = 1:lineLength
    midPoint = linePoints(i,:);
    
    % Calculate start and end points for perpendicular line
    halfWidth = width/2;
    dx = halfWidth * cos(perpAngle);
    dy = halfWidth * sin(perpAngle);
    
    % Calculate start and end points
    perpStart = round([midPoint(1) - dx, midPoint(2) - dy]);
    perpEnd = round([midPoint(1) + dx, midPoint(2) + dy]);
    
    % Call gridMaskLineSegment with explicit start and end points
    perpMask = gridMaskLineSegment(data, perpStart, perpEnd, []);
    
    masks(:,:,i) = perpMask;
end

% Create comment for logging
comment = sprintf('gridDirectionalMask(datasize:%s x %s, width:%d)|%s', ...
    mat2str(size(data,1)), mat2str(size(data,2)), width, mainComment);

    function createDragHandles()
        % Calculate handle positions
        lineVector = [endPoint(1)-startPoint(1), endPoint(2)-startPoint(2)];
        perpVector = [-lineVector(2), lineVector(1)];
        perpVector = perpVector / norm(perpVector) * (width/2);
        
        % Create drag handles on both sides of the line
        dragHandles = [
            plot(startPoint(1) + perpVector(1), startPoint(2) + perpVector(2), 'bs', ...
                'MarkerFaceColor', 'b', 'MarkerSize', 8, 'Tag', 'dragHandle'),
            plot(startPoint(1) - perpVector(1), startPoint(2) - perpVector(2), 'bs', ...
                'MarkerFaceColor', 'b', 'MarkerSize', 8, 'Tag', 'dragHandle')
        ];
        
        % Make handles draggable
        set(dragHandles, 'ButtonDownFcn', @startDragging);
    end

    function startDragging(src, ~)
        if strcmp(get(src, 'Tag'), 'dragHandle')
            isDragging = true;
            set(gcf, 'Pointer', 'fleur');
        end
    end

    function stopDragging(~, ~)
        isDragging = false;
        set(gcf, 'Pointer', 'arrow');
    end

    function updateDragging(~, ~)
        if isDragging
            % Get current mouse position
            currentPos = get(gca, 'CurrentPoint');
            mouseX = currentPos(1,1);
            mouseY = currentPos(1,2);
            
            % Calculate new width based on perpendicular distance to line
            newWidth = 2 * abs((mouseY-startPoint(2))*(endPoint(1)-startPoint(1)) - ...
                (mouseX-startPoint(1))*(endPoint(2)-startPoint(2))) / ...
                norm(endPoint-startPoint);
            
            % Update width and visualization
            width = newWidth;
            updateRectangle();
            createDragHandles();
        end
    end

    function updateRectangle()
        % Calculate rectangle corners
        lineVector = [endPoint(1)-startPoint(1), endPoint(2)-startPoint(2)];
        perpVector = [-lineVector(2), lineVector(1)];
        perpVector = perpVector / norm(perpVector) * (width/2);
        
        corners = [
            startPoint + perpVector;
            endPoint + perpVector;
            endPoint - perpVector;
            startPoint - perpVector;
            startPoint + perpVector  % Close the rectangle
            ];
        
        % Update rectangle
        delete(rectHandle);
        if ~isempty(dragHandles)
            delete(dragHandles);
        end
        
        rectHandle = line(corners(:,1), corners(:,2), ...
            'Color', 'blue', 'LineStyle', '--');
    end

    function confirmWidth(~,~)
        uiresume(gcf);
        close(gcf);
    end
end
