function test_line_masks()
    % Create a test image size
    imageSize = [50, 20];
    topo = zeros(imageSize); % dummy topo data
    
    % Let user draw a line
    figure('Name', 'Draw a line');
    imagesc(topo);
    axis equal tight
    title('Click two points to define a line');
    
    % Get two points from user
    [x, y] = ginput(2);
    startPoint = round([x(1), y(1)]);
    endPoint = round([x(2), y(2)]);
    
    % Get masks from both methods
    [currentMask, ~, ~, ~, ~] = gridMaskLineSegment(topo, startPoint, endPoint);
    [proposedMask, ~, ~, ~, ~] = gridMaskLineSegment(topo, startPoint, endPoint, [],1);
    
    % Plot results
    figure('Name', 'Comparison');
    
    subplot(1,2,1)
    imagesc(currentMask)
    title('Current Method')
    axis equal tight
    
    subplot(1,2,2)
    imagesc(proposedMask)
    title('Proposed Method')
    axis equal tight
end

% Test coordinate system in gridMaskLineSegment
function test_line_segment_coordinates()
    % Create a test image
    test_data = zeros(100, 100);
    
    % Test case 1: Horizontal line
    start_point = [20, 50];  % [x, y]
    end_point = [80, 50];
    
    [mask1, ~, ~, ~, ~] = gridMaskLineSegment(test_data, start_point, end_point, []);
    
    % Test case 2: Vertical line
    start_point = [50, 20];  % [x, y]
    end_point = [50, 80];
    
    [mask2, ~, ~, ~, ~] = gridMaskLineSegment(test_data, start_point, end_point, []);
    
    % Visualize results
    figure('Name', 'Coordinate System Test');
    
    subplot(2,2,1);
    imagesc(mask1);
    title('Horizontal Line Mask');
    axis equal tight
    hold on
    plot([20, 80], [50, 50], 'r--', 'LineWidth', 2);
    xlabel('x');
    ylabel('y');
    
    subplot(2,2,2);
    imagesc(mask2);
    title('Vertical Line Mask');
    axis equal tight
    hold on
    plot([50, 50], [20, 80], 'r--', 'LineWidth', 2);
    xlabel('x');
    ylabel('y');
    
    % Show where the ones are in the mask
    [y1, x1] = find(mask1);
    [y2, x2] = find(mask2);
    
    subplot(2,2,3);
    plot(x1, y1, 'b.');
    title('Horizontal Line Mask Points');
    axis equal
    grid on
    xlabel('x');
    ylabel('y');
    
    subplot(2,2,4);
    plot(x2, y2, 'b.');
    title('Vertical Line Mask Points');
    axis equal
    grid on
    xlabel('x');
    ylabel('y');
    
    % Print some debug info
    fprintf('Horizontal line mask points:\n');
    fprintf('x: %s\n', mat2str(x1(1:min(5,end))));
    fprintf('y: %s\n', mat2str(y1(1:min(5,end))));
    
    fprintf('\nVertical line mask points:\n');
    fprintf('x: %s\n', mat2str(x2(1:min(5,end))));
    fprintf('y: %s\n', mat2str(y2(1:min(5,end))));
end

