% Define the directory where your PNG images are stored
imageDir = 'G:\Dong\OneDrive - phas.ubc.ca\300Science\320 PtSn4_phD\323 Data processing and plotting\Gridmap&QPI_processing\DFT videoes\DFT_Selfcorr_kz5'; % Update this to your images' directory

% Define the directory where you want to save the output video
outputDir = imageDir; % Update this to your desired output directory

% Define the output video file name
outputFileName = 'outputVideo.mp4'; % You can change the file extension to .avi or .mp4 depending on your preference

% Create the full path for the output video
outputVideoPath = fullfile(outputDir, outputFileName);

% Get a list of PNG files in the directory
pngFiles = [dir(fullfile(imageDir, '*.png'))];
%%
% Create a VideoWriter object with the full path
v = VideoWriter(outputVideoPath, 'MPEG-4'); % You can change 'MPEG-4' to another format if needed

% Set the frame rate (frames per second)
v.FrameRate = 10; % Adjust this value as needed

% Open the video writer
open(v);

% Verify that the file list is not empty
if isempty(pngFiles)
    error('No PNG files found. Check the directory path and file extensions.');
end

% Loop through each PNG file
for idx = 1:length(pngFiles)
    % Full path to the PNG image
    pngFileName = fullfile(imageDir, pngFiles(idx).name);
    
    % Read the PNG image
    img = imread(pngFileName);
    
    % Convert the image to uint8 if it's not already
    if ~isa(img, 'uint8')
        img = im2uint8(img);
    end
    
    % Resize the image if necessary to match the first frame's size
    if idx == 1
        refSize = size(img);
    else
        if any(size(img) ~= refSize)
            img = imresize(img, refSize(1:2)); % Resize to match the first image's size
        end
    end
    
    % Write the frame to the video
    writeVideo(v, img);
end

% Close the video writer
close(v);

disp(['Video saved to: ', outputVideoPath]);
