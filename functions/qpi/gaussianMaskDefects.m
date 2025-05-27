function [Y_masked, defect_centers, comment] = gaussianMaskDefects(Y, threshold_slice, num_defect_type)
    % Apply Gaussian masking to defects in 3D data
    % g_M(r,E) = g(r,E) × (1 - M(r - r_0, σ))
    % M is a truncated Gaussian with maximum value = 0.99, it is applied within 1 sigma from the defect center
    % σ is approximately the radius of the defect.
    %
    % Inputs:
    %   Y: 3D data array [height x width x depth]
    %   threshold_slice: (optional) slice number to use for defect selection
    %                    if not provided, will ask user to select
    %   num_defect_type: number of different types of defects to mask
    %
    % Outputs:
    %   Y_masked: 3D data with defects masked using Gaussian suppression
    %   defect_centers: cell array containing centers of selected defects for each type
    %   comment: string containing information about the masking operation
    
    % Input validation
    validateattributes(Y, {'numeric'}, {'3d', 'finite', 'nonnan'});
    
    % Get threshold slice
    if nargin < 2 || isempty(threshold_slice)
        threshold_slice = selectSlice(Y);
    end
    validateattributes(threshold_slice, {'numeric'}, {'scalar', 'integer', 'positive', '<=', size(Y,3)});
    
    defect_centers = cell([1,num_defect_type]);
    % Get defect centers
    Y_masked= Y;
    comment = sprintf("gaussianMaskDefects(threshold_slice:%d, num_defect_type:%d)|", threshold_slice, num_defect_type);
    
    for i = 1:num_defect_type
        fprintf('Select activation for defect type %d\n',i);
        defect_centers{i} = selectDefectCenters(Y_masked(:,:,threshold_slice));
        if isempty(defect_centers)
            disp('No defect centers selected');
        end
        % Define radii for each defect
        sigmas = defineDefectRadii(Y(:,:,threshold_slice), defect_centers{i});
        % Apply Gaussian masks
        [Y_masked, ~] = applyGaussianMasks(Y_masked, defect_centers{i}, sigmas);
        % Display results
        displayResults(Y, Y_masked, threshold_slice, defect_centers{i}, sigmas);
        
        % Add defect information to comment
        comment = sprintf("%s Defect type %d: %d defects, sigmas=[%s]|", ...
            comment, i, size(defect_centers{i},1), mat2str(sigmas',2));
    end
end

function slice_num = selectSlice(Y)
    % Let user select a slice for defect selection
    f = figure('Name', 'Select Slice', 'Position', [100, 100, 800, 600]);
    d3gridDisplay(Y, 'dynamic');
    slice_num = input('Enter slice number for selecting defects: ');
    close(f);
end

function centers = selectDefectCenters(slice_data)
    % Let user select defect centers
    f = figure('Name', 'Defect Selection', 'Position', [100, 100, 800, 600]);
    imagesc(slice_data);
    colormap('parula'); colorbar; axis image;
    clim([min(slice_data(:)), max(slice_data(:))]);
    title('Select defect centers (click points, press Enter when done)');
    
    [x, y] = getpts;
    centers = [x, y];
    close(f);
end

function sigmas = defineDefectRadii(slice_data, defect_centers)
    % Define radii for each defect center
    sigmas = zeros(size(defect_centers, 1), 1);
    f = figure('Name', 'Define Radii', 'Position', [100, 100, 800, 600]);
    
    % Default radius (can be adjusted as needed)
    default_radius = 0.1;
    pre_rad = default_radius;
    for i = 1:size(defect_centers, 1)
        % Display current defect
        clf;
        imagesc(slice_data);
        colormap('parula'); colorbar; axis image;
        caxis([min(slice_data(:)), max(slice_data(:))]);
        
        center = defect_centers(i,:);
        hold on;
        plot(center(1), center(2), 'r+', 'MarkerSize', 1, 'LineWidth', 0.2);
        
        % Create radius display and edit box
        radius_text = uicontrol('Style', 'text', ...
            'String', 'Radius: ', ...
            'Position', [10, 10, 60, 20]);
        radius_edit = uicontrol('Style', 'edit', ...
            'String', num2str(pre_rad), ...
            'Position', [70, 10, 60, 20], ...
            'Callback', @(src,evt) updateRadius(src, center));
        
        % Create Confirm button
        confirm_button = uicontrol('Style', 'pushbutton', ...
            'String', 'Confirm', ...
            'Position', [140, 10, 80, 20], ...
            'Callback', @(src,evt) uiresume(f));
        
        % Create circle with default radius
        h = drawcircle('Center', center, 'Radius', pre_rad, 'Color', 'r', 'FaceAlpha', 0.1);
        
        % Add listeners to keep circle centered and update radius display
        addlistener(h, 'ROIMoved', @(src,evt) handleROIMoved(src, center, radius_edit));
        
        % Wait for button press
        uiwait(f);
        
        % Get final radius and compute sigma
        radius = h.Radius;
        sigmas(i) = radius;
        pre_rad = radius;
        % Draw final circle
        th = 0:pi/50:2*pi;
        plot(radius * cos(th) + center(1), radius * sin(th) + center(2), 'r--', 'LineWidth', 1.5);
    end
    close(f);
    
    function handleROIMoved(src, center, radius_edit)
        % Handle both center and radius changes
        if isvalid(src)
            % Force center to stay at defect point
            src.Center = center;
            % Update radius display
            radius_edit.String = num2str(src.Radius, '%.1f');
        end
    end
    
    function updateRadius(src, center)
        % Update circle when radius is edited
        new_radius = str2double(src.String);
        if ~isnan(new_radius) && new_radius > 0
            delete(findobj(gca, 'Type', 'images.roi.Circle'));
            h = drawcircle('Center', center, 'Radius', new_radius, 'Color', 'r', 'FaceAlpha', 0.1);
            addlistener(h, 'ROIMoved', @(src,evt) handleROIMoved(src, center, radius_edit));
        end
    end
end

function [Y_masked, defect_mask] = applyGaussianMasks(Y, defect_centers, sigmas)
    % Apply Gaussian masks to the data
    Y_masked = Y;
    defect_mask = false(size(Y));
    [X, Y_coord] = meshgrid(1:size(Y,2), 1:size(Y,1));
    
    for i = 1:size(Y, 3)
        mask = ones(size(Y,1), size(Y,2));
        for j = 1:size(defect_centers, 1)
            r0 = defect_centers(j,:);
            % Calculate distance from each point to defect center
            distance_squared = (X-r0(1)).^2 + (Y_coord-r0(2)).^2;
            distance = sqrt(distance_squared);
            
            sigma = sigmas(j);
            % Create smooth transition around 3 sigma
            step_loc = 2*sigma;  % Start transition before 3 sigma
            step_shapeness = 10;
            % Create smooth step function as a function handle
            smooth_step_fn = @(d, loc, shape) 0.5 + 0.5*(tanh(-shape*(d-loc)));
            smooth_step = smooth_step_fn(distance, step_loc, step_shapeness);
            
            %Create gaussian with smooth transition
            gaussian = 0.99 * exp(-distance_squared/(2*sigma^2)) .* smooth_step;

            % Update mask
            mask = mask .* (1 - gaussian);
        end
        Y_masked(:,:,i) = Y(:,:,i) .* mask;
        defect_mask(:,:,i) = mask;
    end
end

function displayResults(Y, Y_masked, threshold_slice, defect_centers, sigmas)
    invgray = flipud(gray);
    % Display the results
    figure('Name', 'Masking Result', 'Position', [100, 100, 1800, 800]);
    Y_slice = Y(:,:,threshold_slice);
    Y_masked_slice = Y_masked(:,:,threshold_slice);
    Y_inverse_mask_slice = Y_slice - Y_masked_slice;

    % Calculate QPI (2D FFT)
    Y_fft = fftshift(abs(fft2(Y_slice)));
    Y_masked_fft = fftshift(abs(fft2(Y_masked_slice)));
    Y_inverse_fft = fftshift(abs(fft2(Y_inverse_mask_slice)));
    
    % Normalize FFT for better visualization
    Y_fft = log10(Y_fft + 1);
    Y_masked_fft = log10(Y_masked_fft + 1);
    Y_inverse_fft = log10(Y_inverse_fft + 1);

    % Real space images (first row)
    subplot(2,3,1);
    imagesc(Y_slice);
    colorbar; title('Original Data'); axis image;
    caxis([min(Y_slice(:)), max(Y_slice(:))]);
    colormap(gca, invgray);
    
    subplot(2,3,2);
    imagesc(Y_masked_slice);
    colorbar; title('After Gaussian Masking'); axis image;
    caxis([min(Y_slice(:)), max(Y_slice(:))]);
    colormap(gca, invgray);
    
    subplot(2,3,3);
    imagesc(Y_inverse_mask_slice);
    colorbar; title('Inverse mask'); axis image;
    caxis([min(Y_slice(:)), max(Y_slice(:))]);
    colormap(gca, invgray);
    
    % QPI images (second row)
    subplot(2,3,4);
    imagesc(Y_fft);
    colorbar; title('QPI (Original)'); axis image;
    colormap(gca, invgray);
    caxis auto;
    
    subplot(2,3,5);
    imagesc(Y_masked_fft);
    colorbar; title('QPI (Masked)'); axis image;
    colormap(gca, invgray);
    caxis auto;
    
    subplot(2,3,6);
    imagesc(Y_inverse_fft);
    colorbar; title('QPI (Inverse)'); axis image;
    colormap(gca, invgray);
    caxis auto;

    % Print parameters
    fprintf('\nGaussian Masking Parameters:\n');
    fprintf('Number of defects masked: %d\n', size(defect_centers, 1));
    for i = 1:size(defect_centers, 1)
        fprintf('Defect %d: position (%.1f, %.1f), σ = %.1f pixels\n', ...
            i, defect_centers(i,1), defect_centers(i,2), sigmas(i));
    end
end 