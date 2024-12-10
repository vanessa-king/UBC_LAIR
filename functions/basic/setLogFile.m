function [LOGpath,LOGfile] = setLogFile(fileBool)
%UI to select file / directory + set name for LOGpath and LOGfile 
%   User input via UI to select a file (folder). If no file is picked the
%   user is prompted to set a file name, which is set to be unique via
%   appending a running number. The optional variable fileBool defines if a
%   file is chosen or a folder. It defaults to chosing a folder.
%   If the execution is aborted returns [0, 0]

%   M. Altthaler 2022; edited 2024/12

arguments
    fileBool logical =0
end

    if fileBool == 0
        %uigetdir + name prompt
        LOGpath = uigetdir();
        if LOGpath == 0
            LOGfile = 0;
        else
            LOGfile = uniqueLOGNamePrompt(LOGpath,'NewProject');
        end
    elseif fileBool == 1
        %uigetfile sets the dir and name
        [LOGpath,TempFile,~] = selectData();
        if LOGpath == 0
            LOGfile = 0;
        else
            LOGfile = uniqueLOGNamePrompt(LOGpath,TempFile);
        end
    end

end

%%%%%%%%%%%%%%%%%%%%%% local helper functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [nameString] = uniqueLOGNamePrompt(filepath, defaultName)
%User prompt to specify a unique name for the LOG file and check if the file
%already exists. In that case a running number is appended. 
%   Returns a string containing a unique <name> for the log file. The <name> 
%   is specified by the user via a command window promt. Note:  
%       The <name> given will result in a file: <name>_LOGfile.txt
%   The function can be called with a default <name>. Additionally the 
%   function checks if a file of the same <name> already exists. If a file 
%   with the same <name>_LOGfile already exists the function appends a 
%   number string in the format '_###', yielding nameString = <name>_001, 
%   i.e. <name>_001_LOGfile.txt. The '_###' appended <name> is then 
%   rechecked and the number counts up ('_002', ...) until a unique name is
%   generated. 
%   
%   Note if you run the initialize block with the same name multiple times
%   this will ensure no LOG file is ever overwritten!   


%   arguments
%   filepath:       directory checked for duplicate names, i.e. the one the 
%                   LOG file is supposed ot be saved in.
%   defaultName:    specifies <name> the LOG file defaults to if no user 
%                   input is given. If no name is parsed: <name>="Project"
%
%   M. Altthaler, April 2024


arguments
    filepath        {mustBeText}=''
    defaultName     {mustBeText}="Project"
end

%fill in current folder in case no filepath is given
if isempty(filepath)
    filepath = pwd;
end

%ask for user input of name and tag
%user specified figure name
prompt = strcat("Please type the <name> for '<name>_LOGfile' [",defaultName,"]:");
nameString = input(prompt,"s");
if isempty(nameString)
    nameString = defaultName;
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
        if strcmp(filename,strcat(testNameString,"_LOGfile"))
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