function [dataOut] = nestedStructCall(data,dataset,varInString)
%allows to pass <AAA>.<BBB> as varInString to access nested struct variables like data.<dataset>.<AAA>.<BBB>
%   varInString can be nested multiple times with '.' as the seperator. 
%   E.g. "AAA.BBB.CCC.DDD" yields dataOut = data.dataset.AAA.BBB.CCC.DDD
%   If any (nested) field does not exist, the function will return an
%   error.

% M. Altthaler 04/2025;

arguments
    data        
    dataset     {mustBeText}
    varInString {mustBeText}
end

%ensure string (not char array)
varInString = convertCharsToStrings(varInString);

if isfield(data,dataset)
    if contains(varInString,".")
        partialVarInString = split(varInString,".");
        currentStruct = data.(dataset);
        for n = 1:length(partialVarInString)-1
            if isfield(currentStruct,partialVarInString(n))
                currentStruct = currentStruct.(partialVarInString(n));
            else
                error("data.%s.%s does not exist!", dataset, strjoin(partialVarInString(1:n),"."));
            end
        end
        if isfield(currentStruct,partialVarInString(end))
            dataOut = currentStruct.(partialVarInString(end));
        else
            error("data.%s.%s does not exist!", dataset, varInString);
        end
    else
        dataOut = data.(dataset).(varInString);
    end
else
    error("data.%s does not exist!", dataset);
end

end