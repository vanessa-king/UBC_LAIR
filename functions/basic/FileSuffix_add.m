function FileSuffix_add(directory, suffix, includeSubfolders)
%addSuffixToFiles Adds a suffix to the names of files in a directory
%   This function renames all files in the specified directory by adding a
%   given suffix to their names while preserving their original extensions.
%   The function can also include files in subdirectories if specified.
%   
%   Usage:
%       addSuffixToFiles(directory, suffix, includeSubfolders)
%
%   Arguments:
%       directory (string)         - Path to the directory containing the files.
%       suffix (string)            - Suffix to be added to the file names.
%       includeSubfolders (logical) - Whether to include files in subfolders.
%
%   Example:
%       addSuffixToFiles('path/to/directory', '_historical', true)
%
%   D.Chen July 2024

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