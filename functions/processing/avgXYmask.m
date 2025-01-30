function [data_masked, avg_out, STD_out, comment] = avgXYmask(data, mask, returnNaNbool)
% averaging I(V) or dIdV data in x and y for the area determined by the mask
%   The function takes I(V) or dIdV data of the format data(x,y,V) and
%   applies the mask of corresponding size xy to the data, which is returend 
%   as data_masked. Subsequently the masked data is averaged in xy yielding 
%   didv_avg.
 
% arguments
%   data            I(V) or didv sprectra of the grid, format: data(x,y,V)
%   mask            2D logical map of dimension xy matching data
%   returnNaNbool   0: data_masked is returned with zeros, 
%                   1: data_masked is returned with NaN. 

% returns 
%   didv_masked     masked didv data: NaN for all xy that were 0 in the mask 
%   avg_out         array of xy averaged values of didv_masked  
%   STD_out         standard veviation corresponding to avg_out
%   comment         for logging the function call

%   Nov. 2023 - Markus Altthaler, June 2024 - M. Altthaler;  edited M.
%   Altthaler 2024/12; Rysa Jan 2025

arguments
    data
    mask            = ones(size(data, [1,2]))
    returnNaNbool   = 0
end

%catch specil expeption if [] is parsed as maks to edit 3rd argument
if isempty(mask)
    mask = ones(size(data, [1,2]));
end

%LOG comment of function call
comment = sprintf("avgMaskFast(didv:%s x %s x %s, mask:%s x %s, returnNaNbool: %s)|", mat2str(size(data,1)), mat2str(size(data,2)), mat2str(size(data,3)), mat2str(size(mask, 1)), mat2str(size(mask, 2)), num2str(returnNaNbool));

%mask: 0 -> NaN
mask(mask==0) = NaN;

%applying mask to data (triv. extendsion in 3rd dim applies) 
data_masked = data.*mask;

%averaging & standard deviation; dimensions: 1x1xn -> nx1
avg_out = mean(data_masked,[1,2],"omitnan");
avg_out = squeeze(avg_out);
STD_out = std(data_masked,1,[1,2],"omitnan"); %note TBD is w=0 or w=1 is the right way to do it (see documentation for details)
STD_out = squeeze(STD_out);

if returnNaNbool == 0 
    %data_masked NaN->0 (can be suppressed to return NaN instead)
    data_masked(isnan(data_masked)) = 0; 
end

end