function B = construct_cv2_img(A)
    % Check if the image is RGB    
    % Turn rgb to gray scale
    [rows, cols, channels] = size(A);

    if channels == 3
    A = rgb2gray(A); % Convert to grayscale if it's a color image
    end

    % Size of the input image A
    [n, ~] = size(A);
    
    % Pre-allocate B with zeros
    B = zeros(2*n, 2*n);
    
    % Fill the second quadrant of B with A
    B(n+1:end, n+1:end) = A;
    
    % Fill the first quadrant with A flipped horizontally
    B(n+1:end, 1:n) = fliplr(A);
    
    % Fill the third quadrant with A flipped horizontally and then vertically
    B(1:n, 1:n)  = flipud(fliplr(A));
    
    % Fill the fourth quadrant with A flipped vertically
    B(1:n, n+1:end)  = flipud(A);
   
    % Plot A
    subplot(1, 2, 1);
    imagesc(A);
    axis equal tight;
    colormap(gray);
    title('pre construct');
    
    % Plot B
    subplot(1, 2, 2);
    imagesc(B);
    axis equal tight;
    colormap(gray);
    title('post construct');
end