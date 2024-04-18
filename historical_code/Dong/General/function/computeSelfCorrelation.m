function selfCorr = computeSelfCorrelation(img)
    
    % Check if the image is color and convert to grayscale
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    
    % Compute the self-correlation using xcorr2
    selfCorr = xcorr2(double(img));
    % to remove the artificial distribution of the selfcorr of a unity matrix
    selfCorr = selfCorr-xcorr2(ones(size(img)));
    
    % Display the self-correlation result
    %figure;
    %imagesc(selfCorr);
    %axis equal tight;
    %colormap(jet);
    %colorbar;
    %title('Self-Correlation of the Image');
end
