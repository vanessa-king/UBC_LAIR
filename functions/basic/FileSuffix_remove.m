function FileSuffix_remove(directory, suffix, includeSubfolders)
%removeSuffixFromFiles Removes a specified suffix from the names of files
%   This function renames all files in the specified directory by removing
%   a given suffix from their names while preserving their original extensions.
%   The function can also include files in subdirectories if specified.
%   
%   Usage:
%       removeSuffixFromFiles(directory, suffix, includeSubfolders)
%
%   Arguments:
%       directory (string)         - Path to the directory containing the files.
%       suffix (string)            - Suffix to be removed from the file names.
%       includeSubfolders (logical) - Whether to include files in subfolders.
%
%   Example:
%       removeSuffixFromFiles('path/to/directory', '_historical', true)
%
%   D.Chen, July 2024

arguments
    directory {mustBeText} = ""
    suffix {mustBeText} = "_suffix"
    includeSubfolders {mustBeNumericOrLogical} = false
end

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