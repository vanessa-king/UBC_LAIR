function removeSuffixFromFiles(directory, suffix, includeSubfolders)
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
            
            % Check if the file name ends with the suffix
            if endsWith(name, suffix)
                % Construct the new file name without the suffix
                newName = extractBefore(name, strlength(name) - strlength(suffix) + 1);
                oldFile = fullfile(directory, fileList(i).name);
                newFile = fullfile(directory, [newName, ext]);
                
                % Rename the file
                movefile(oldFile, newFile);
                fprintf('Renamed: %s -> %s\n', fileList(i).name, [newName, ext]);
            end
        elseif includeSubfolders && fileList(i).isdir && ~strcmp(fileList(i).name, '.') && ~strcmp(fileList(i).name, '..')
            % Recursively call the function for subfolders if includeSubfolders is true
            subfolder = fullfile(directory, fileList(i).name);
            removeSuffixFromFiles(subfolder, suffix, includeSubfolders);
        end
    end
end
