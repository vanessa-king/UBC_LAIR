function [masks, comment] = maskSingleDirectional(data, connected, startPoint, endPoint)
%Average grid along a given direction with interactive width selection
% Arguments:
%   data        2D or 3D array containing the data.
%   connected   logical flag for side connectivity (optional, default false)
%   startPoint  [x1,y1] start point coordinates (optional)
%   endPoint    [x2,y2] end point coordinates (optional)
%
% Returns:
%   masks       3D array of logical masks (data_dim x data_dim x L)
%   comment     Comment for logging the function call.
% Dec 2024 - Dong Chen

arguments
    data
    connected logical = false
    startPoint {mustBeNumeric, mustBePositive} = []
    endPoint {mustBeNumeric, mustBePositive} = []
end

% Declare global state
global UI_STATE

% Initialize state structure
UI_STATE = struct();
UI_STATE.width = 10;
UI_STATE.isDragging = false;
UI_STATE.rectHandle = [];
UI_STATE.dragHandles = [];
UI_STATE.widthField = [];

% Get main line and initialize vectors
[mainMask, mainComment, UI_STATE.startPoint, UI_STATE.endPoint, polcoord] = ...
    gridMaskLineSegment(data, startPoint, endPoint, [], connected);

if isempty(UI_STATE.startPoint) || isempty(UI_STATE.endPoint)
    error('Line selection was cancelled or invalid');
end

% Calculate and store main vectors
UI_STATE.lineVector = UI_STATE.endPoint - UI_STATE.startPoint;
UI_STATE.perpVector = [-UI_STATE.lineVector(2), UI_STATE.lineVector(1)];
UI_STATE.perpVector = UI_STATE.perpVector / norm(UI_STATE.perpVector);

% Create UI for width selection
createWidthSelectionUI(data);

% Wait for user confirmation
uiwait(gcf);

% Generate masks using global state
masks = generatePerpMasks(data, mainMask);

% Visualize final sum of masks
figure('Name', 'Final Directional Mask Result');
imagesc(permute(sum(masks,3), [2,1]));
hold on
% Plot the main line
line([UI_STATE.startPoint(1), UI_STATE.endPoint(1)], ...
     [UI_STATE.startPoint(2), UI_STATE.endPoint(2)], ...
     'Color', 'red', 'LineWidth', 1.5);
axis xy
axis equal
colorbar;
title(sprintf('Sum of All Perpendicular Masks (width=%d)', UI_STATE.width));

% Create comment for logging
comment = sprintf('maskSingleDirectional(datasize:%s x %s, width:%d)|%s', ...
    mat2str(size(data,1)), mat2str(size(data,2)), UI_STATE.width, mainComment);

% Clear global state
clear global UI_STATE
end

%% Helper functions

function createWidthSelectionUI(data)
    global UI_STATE
    
    % Create figure
    figure('WindowButtonMotionFcn', @updateRectangle);
    imagesc(permute(data, [2,1,3]));
    axis xy
    axis equal
    hold on
    
    % Draw original line
    line([UI_STATE.startPoint(1), UI_STATE.endPoint(1)], ...
         [UI_STATE.startPoint(2), UI_STATE.endPoint(2)], ...
         'Color', 'red', 'LineWidth', 1.5);
    
    % Add width display/edit field
    widthField = uicontrol('Style', 'edit', ...
        'String', num2str(UI_STATE.width), ...
        'Position', [10 50 100 30], ...
        'Callback', @updateWidthFromText);
    
    % Update state with widthField handle
    UI_STATE.widthField = widthField;
    
    % Add width label
    uicontrol('Style', 'text', ...
        'String', 'Width:', ...
        'Position', [10 80 100 20], ...
        'BackgroundColor', get(gcf, 'Color'));
    
    % Add confirm button
    uicontrol('Style', 'pushbutton', ...
        'String', 'Confirm Width', ...
        'Position', [10 10 100 30], ...
        'Callback', @confirmWidth);
    
    % Set figure callbacks for dragging
    set(gcf, 'WindowButtonDownFcn', @startDragging);
    set(gcf, 'WindowButtonUpFcn', @stopDragging);
    set(gcf, 'WindowButtonMotionFcn', @updateDragging);
    
    % Initial visualization
    updateRectangle();
    createDragHandles();
    
    % Modify all nested functions to use global UI_STATE instead of state
    function updateWidthFromText(src, ~)
        newWidth = round(str2double(get(src, 'String')));
        
        % Basic validation
        if isnan(newWidth) || newWidth <= 0
            set(src, 'String', num2str(UI_STATE.width));
            return;
        end
        
        % Check if new width would exceed bounds
        perpVector_scaled = UI_STATE.perpVector * newWidth/2;
        corners = [
            UI_STATE.startPoint + perpVector_scaled;
            UI_STATE.endPoint + perpVector_scaled;
            UI_STATE.endPoint - perpVector_scaled;
            UI_STATE.startPoint - perpVector_scaled
        ];
        
        % Check if any corner would be out of bounds
        data_size = size(data);
        for i = 1:size(corners,1)
            if any(corners(i,:) < 1) || ...
               corners(i,1) > data_size(1) || ...
               corners(i,2) > data_size(2)
                % Revert to previous width if new width would exceed bounds
                set(src, 'String', num2str(UI_STATE.width));
                return;
            end
        end
        
        % If we get here, the new width is valid
        UI_STATE.width = newWidth;
        updateRectangle();
        createDragHandles();
    end
    
    function startDragging(src, ~)
        if strcmp(get(src, 'Tag'), 'dragHandle')
            UI_STATE.isDragging = true;
            set(gcf, 'Pointer', 'fleur');
        end
    end
    
    function stopDragging(~, ~)
        UI_STATE.isDragging = false;
        set(gcf, 'Pointer', 'arrow');
    end
    
    function confirmWidth(~, ~)
        fprintf('Final width confirmed: %d\n', UI_STATE.width);
        fprintf('Line vector: [%.2f, %.2f]\n', UI_STATE.lineVector(1), UI_STATE.lineVector(2));
        fprintf('Perpendicular vector: [%.2f, %.2f]\n', UI_STATE.perpVector(1), UI_STATE.perpVector(2));
        uiresume(gcf);
        close(gcf);
    end
    
    function updateDragging(~, ~)
        if UI_STATE.isDragging
            % Get current point in axis coordinates
            currentPos = get(gca, 'CurrentPoint');
            mousePoint = [currentPos(1,1), currentPos(1,2)];
            
            % Calculate new width as twice the distance from point to line
            newWidth = round(2 * pointToLineDistance(mousePoint));
            
            % Calculate potential corner positions with new width
            perpVector_scaled = UI_STATE.perpVector * newWidth/2;
            corners = [
                UI_STATE.startPoint + perpVector_scaled;
                UI_STATE.endPoint + perpVector_scaled;
                UI_STATE.endPoint - perpVector_scaled;
                UI_STATE.startPoint - perpVector_scaled
            ];
            
            % Check if any corner would be out of bounds
            data_size = size(data);
            for i = 1:size(corners,1)
                if any(corners(i,:) < 1) || ...
                   corners(i,1) > data_size(1) || ...
                   corners(i,2) > data_size(2)
                    % Skip update if any corner would be outside data bounds
                    return;
                end
            end
            
            % If we get here, the new width is valid
            UI_STATE.width = newWidth;
            set(UI_STATE.widthField, 'String', num2str(UI_STATE.width));
            updateRectangle();
            createDragHandles();
        end
    end
    
    function distance = pointToLineDistance(point)
        lineVector = UI_STATE.lineVector;
        pointVector = point - UI_STATE.startPoint;
        
        % Calculate perpendicular distance using cross product
        distance = abs(lineVector(1)*pointVector(2) - lineVector(2)*pointVector(1)) / ...
            norm(lineVector);
    end
    
    function updateRectangle()
        % Use the already calculated perpVector scaled by width/2
        perpVector_scaled = UI_STATE.perpVector * UI_STATE.width/2;
        
        corners = [
            UI_STATE.startPoint + perpVector_scaled;
            UI_STATE.endPoint + perpVector_scaled;
            UI_STATE.endPoint - perpVector_scaled;
            UI_STATE.startPoint - perpVector_scaled;
            UI_STATE.startPoint + perpVector_scaled  % Close the rectangle
            ];
        
        % Update rectangle
        delete(UI_STATE.rectHandle);
        if ~isempty(UI_STATE.dragHandles)
            delete(UI_STATE.dragHandles);
        end
        
        UI_STATE.rectHandle = line(corners(:,1), corners(:,2), ...
            'Color', 'blue', 'LineStyle', '--');
    end
    
    function createDragHandles()
        % Calculate handle positions using perpVector
        perpVector_scaled = UI_STATE.perpVector * UI_STATE.width/2;
        
        % Create drag handles on both sides of the line
        UI_STATE.dragHandles = [
            plot(UI_STATE.startPoint(1) + perpVector_scaled(1), ...
                 UI_STATE.startPoint(2) + perpVector_scaled(2), 'bs', ...
                 'MarkerFaceColor', 'b', 'MarkerSize', 8, 'Tag', 'dragHandle'),
            plot(UI_STATE.startPoint(1) - perpVector_scaled(1), ...
                 UI_STATE.startPoint(2) - perpVector_scaled(2), 'bs', ...
                 'MarkerFaceColor', 'b', 'MarkerSize', 8, 'Tag', 'dragHandle')
        ];
        
        % Make handles draggable
        set(UI_STATE.dragHandles, 'ButtonDownFcn', @startDragging);
    end
end

function masks = generatePerpMasks(data, mainMask)
    global UI_STATE
    % Find all points along the main line
    [linePoints_x, linePoints_y] = find(mainMask);
    linePoints = [linePoints_x, linePoints_y];
    lineLength = length(linePoints_x);
    fprintf('Number of points along main line: %d\n\n', lineLength);
    
    % Initialize 3D mask array
    masks = false(size(data,1), size(data,2), lineLength);
    
    % Calculate perpendicular vector scaled by width/2
    perpVector_scaled = UI_STATE.perpVector * UI_STATE.width/2;
    
    % Generate perpendicular line masks
    for i = 1:lineLength
        midPoint = linePoints(i,:);
        
        % Calculate perpendicular start and end points
        perpStart = round(midPoint - perpVector_scaled);
        perpEnd = round(midPoint + perpVector_scaled);
        % print the points
        % Check bounds
        if all(perpStart > 0) && all(perpEnd > 0) && ...
           all(perpStart <= size(data)) && all(perpEnd <= size(data))
            perpMask = gridMaskLineSegment(data, perpStart, perpEnd, []);
            masks(:,:,i) = perpMask;
        else
            warning('Skipping mask at point %d due to bounds', i);
        end
    end
end
