function test_perpendicular_masks()
    % Create test data
    data = zeros(50, 40);
    
    % Define a simple horizontal line
    startPoint = [10, 20];
    endPoint = [30, 20];
    width = 6;
    
    % Call gridDirectionalMask
    [masks, comment] = gridDirectionalMask(data, false, startPoint, endPoint);
    
    % Visualize results
    figure('Name', 'Perpendicular Mask Test');
    
    subplot(2,2,1);
    imagesc(permute(data, [2,1,3]));
    hold on;
    line([startPoint(1), endPoint(1)], [startPoint(2), endPoint(2)], ...
         'Color', 'red', 'LineWidth', 1.5);
    axis xy;
    axis equal;
    title('Original Data with Line');
    
    subplot(2,2,2);
    imagesc(permute(masks(:,:,1), [2,1]));
    axis xy;
    axis equal;
    title('First Perpendicular Mask');
    
    subplot(2,2,3);
    imagesc(permute(masks(:,:,end), [2,1]));
    axis xy;
    axis equal;
    title('Last Perpendicular Mask');
    
    subplot(2,2,4);
    imagesc(permute(sum(masks,3), [2,1]));
    axis xy;
    axis equal;
    title('Sum of All Masks');
end 