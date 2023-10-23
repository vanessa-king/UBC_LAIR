function [LOGpath] = setLOGpath(inputPath, alterBool)
%Set LOGpath for logUsedBlocks() function
%   sets the parsed inputPath as LOGpath unless an alternative path is
%   desired by the user and set via the UI. The user prompt is surpressed 
%   (=0) via alterBool by default and can be activated (=1). 

%   inputPath:  path string, usually the same as the data selected
%   alterBool:  boolean variable to suppress user input for alternative
%               folder

%   Markus Altthaler

arguments
    inputPath   {mustBeText}
    alterBool   {mustBeInteger}=0
end


if alterBool == 0
    %user prompt for change suppressed
    LOGpath = inputPath;
    disp(strcat("Your LOG folder is: ", LOGpath));
end


if alterBool == 1
    %user propt for change granted
    %select LOG file location
    disp(strcat("Your output folder is: ", inputPath));
    prompt = "Do you want to select a different output folder for your LOG file? Y/N [N]: ";
    txt = input(prompt,"s");
    if isempty(txt)
        txt = 'N';
    end

    if txt == 'N'
        %user does not want to change path
        LOGpath = inputPath;
        disp(strcat("Your LOG folder is: ", LOGpath));
    end

    if txt == 'Y'
        %user want to cchange path
        LOGpath = uigetdir('','Select path for LOG files');
        disp(strcat("Your LOG folder is: ", LOGpath));
    end

end


end