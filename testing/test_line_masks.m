function test_line_masks()
    % Create a test image size
    imageSize = [20, 20];
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

