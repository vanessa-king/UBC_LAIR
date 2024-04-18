function [fieldName] = fieldNamePrompt()
%Prompts user to give a field name:
%   Asks for user input to set the field name. The input can either be a
%   prest name or a free input. Free inputs may only contain up to 20
%   letters, i.e. characters: a-z, A-Z.

% M. Altthaler, April 2024
 

    disp('The data file you selected will be saved as data.<name>');
    disp('To default to a preset type *#');
    disp('*1: <name> = grid');
    disp('*2: <name> = topo');
    disp('*3: <name> = topoBefore');
    disp('*4: <name> = topoAfter');
    disp('*5: <name> = IVcurve');
    disp('A freely chosen <name> may only contain capital and non-capital letters!')
    str = input('Please type the <name> you desire:' ,"s");
    switch str
        case '*1'
            fieldName = 'grid';
        case '*2'
            fieldName = 'topo';
        case '*3'
            fieldName = 'topoBefore';
        case '*4'
            fieldName = 'topoAfter';
        case '*5'
            fieldName = 'IVcurve';
        otherwise
            if strlength(str) <21
                %filter space and other fobidden chars!
                str = regexprep(str,'[^a-zA-Z\s]','');
                str = erase(str, " ");
                fieldName = str;
            else
                disp('Name exceeds limit of 20 characters');
            end
    end

end