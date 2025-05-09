function [nameString] = uniqueNamePrompt(defaultName, defaultUniqueTag, filepath)
%User prompt to specify a unique name for a plot and check if the file
%exists already
%   returns a string containing a unique name for a figure that consists of
%   a name and unique tag. The name and tag can be specified by the user 
%   via a command window promt. The function is called with default values 
%   for both variables. Additionally the function checks if a file of the
%   same name already exists. If a file with the same name and tag already 
%   exists the function appends '_001' to the name and tag and rececks. If 
%   that is taken it tires '_002' and so on. (Note if you run a block with
%   default values several times this will make sure you get unique file
%   names!) 
%   
%
%   defaultName: default name for the figure (should describe the figure
%   like 'IV plot', 'topo', ...)
%   defaultUniqueTag: default unique identifier for figure (a, b, c, ...)
%   filepath: directory to be checked for duplicete names, i.e. the one you
%   intend to save your file in
%
%   Markus Altthaler

%   ToDo: check if a file name ends on "_XXX" and set the counter
%   accordingly to name the file _XXX+1 rather than "_XXX_001" !Note may
%   cause problems if uniqueTag is set to XXX!

arguments
    defaultName         {mustBeText}=""
    defaultUniqueTag    {mustBeText}=""
    filepath            {mustBeText}=""
end

%fill in current folder in case no filepath is given
if isempty(filepath)
    filepath = pwd;
end

%ask for user input of name and tag
%user specified figure name
prompt = strcat("Save file as [",defaultName,"]:");
name = input(prompt,"s");
if isempty(name)
    name = defaultName;
end
%user specified figure tag
prompt = strcat("Set unique tag to [",defaultUniqueTag,"]:");
uniqueTag = input(prompt,"s");
if isempty(uniqueTag)
    uniqueTag = defaultUniqueTag;
end
    
%set name based in inputs
%name based on inputs ('_tag' optional)
if uniqueTag == ""
    nameString = name;
else
    nameString = strcat(name,"_",uniqueTag);
end
%default name if no other input is given 
if nameString == ""
    nameString = "Figure";
end

%check if name is unique in the given directory
checkname = 0;
testNameString = nameString;
n = 1;
while checkname == 0
    % Test if the current iteration testNameString is a unique name in the
    % directory
    % Get a list of all files in the current directory
    files = dir(filepath);
    % Initialize a flag to check if the file exists
    fileExists = false;
    % Loop through the files and check if any file matches the given name (ignoring the extension)
    for i = 1:numel(files)
        [~, filename, ext] = fileparts(files(i).name);
        if strcmp(filename, testNameString)
            fileExists = true;
            break;
        end
    end

    if fileExists
        % File exists.
        testNameString = strcat(nameString,"_",sprintf("%03d",n));
        n = n+1;
    else
        % File does not exist.
        % i.e. the assigned testNameString is a unique file name in the directory and will be returned by the function
        nameString = testNameString;
        checkname = 1;
    end
end

end