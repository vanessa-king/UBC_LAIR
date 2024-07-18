function addSuffixToFiles(directory, suffix, includeSubfolders)
    % Check if the input directory exists
    if ~isfolder(directory)
        error('The specified directory does not exist.');
    end
    
    % Get a list of all files and folders in the directory
    fileList = dir(directory);
    
    % Loop through all files and folders in the directory
    for i = 1:length(fileList)
        if ~fileList(i).isdir
            [filepath, name, ext] = fileparts(fileList(i).name);
            
            % Construct the new file name with the suffix
            oldFile = fullfile(directory, fileList(i).name);
            newFile = fullfile(directory, [name, suffix, ext]);
            
            % Rename the file
            movefile(oldFile, newFile);
            fprintf('Renamed: %s -> %s\n', fileList(i).name, [name, suffix, ext]);
        elseif includeSubfolders && fileList(i).isdir && ~strcmp(fileList(i).name, '.') && ~strcmp(fileList(i).name, '..')
            % Recursively call the function for subfolders if includeSubfolders is true
            subfolder = fullfile(directory, fileList(i).name);
            addSuffixToFiles(subfolder, suffix, includeSubfolders);
        end
    end
end
