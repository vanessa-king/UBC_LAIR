function [fieldName] = fieldNamePrompt_historical(fieldNameIn)
%Prompts user to give a field name:
%   Asks for user input to set the field name. The input can either be a
%   prest name or a free input. Free inputs may only contain up to 64
%   letters, numbers and underscores, i.e. characters: a-z, A-Z, 0-9, _. 
%   Any other characters will be removed from the string without warning!

% M. Altthaler, April 2024 & October 2024

arguments
    fieldNameIn {mustBeText}= ""
end
 
    if fieldNameIn == ""
        %no field name parsed - initial setting
        disp('The data file you selected will be saved as data.<name>');
        disp('To default to a preset type #');
        disp('1: <name> = grid');
        disp('2: <name> = topo');
        disp('3: <name> = topoBefore');
        disp('4: <name> = topoAfter');
        disp('5: <name> = IVcurve');
        disp('A freely chosen <name> may only contain capital (A-Z) and non-capital (a-z) letters numbers (0-9) and underscores (_)!')
        str = input('Please type the <name> you desire:' ,"s");
        switch str
            case '1'
                fieldName = 'grid';
            case '2'
                fieldName = 'topo';
            case '3'
                fieldName = 'topoBefore';
            case '4'
                fieldName = 'topoAfter';
            case '5'
                fieldName = 'IVcurve';
            otherwise
                %free name assignment
                %filter space and other fobidden chars!
                str = regexprep(str,'[^a-zA-Z0-9_\s]','');
                str = erase(str, " ");
                if strlength(str) <65
                    fieldName = str;
                else
                    disp('Name exceeds limit of 64 characters');
                end
        end
    else 
        %field name parsed - field already exists
        disp('------------------------------------------------------------------------------')
        strOut = sprintf('The field data.<name> = data.%s is already in use!', fieldNameIn);
        disp(strOut);
        disp('You can overwrite the exising field or chose a new name.');
        disp('To default to a preset type # or type the new name (see above for details)');
        strOut = sprintf('0: overwrite with the chosen name: %s', fieldNameIn);
        disp(strOut);
        str = input('Please type the <name> you desire:' ,"s");
        switch str
            case '0'
                fieldName = fieldNameIn;
            case '1'
                fieldName = 'grid';
            case '2'
                fieldName = 'topo';
            case '3'
                fieldName = 'topoBefore';
            case '4'
                fieldName = 'topoAfter';
            case '5'
                fieldName = 'IVcurve';
            otherwise
                %free name assignment
                %filter space and other fobidden chars!
                str = regexprep(str,'[^a-zA-Z\s]','');
                str = erase(str, " ");
                if strlength(str) <65
                    fieldName = str;
                else
                    disp('Name exceeds limit of 64 characters');
                end
        end    
    end    

end