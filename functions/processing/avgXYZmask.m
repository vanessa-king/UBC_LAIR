function [masked_data, avg_out, STD_out, comment] = avgXYZmask(data, masks, returnNaNbool)
% averaging I(V) or dIdV data in x and y for the area determined by the
% mask with Z layers
%   The function takes I(V) or dIdV data of the format data(x,y,V) and
%   applies the mask of corresponding size xy to the data, which is returend 
%   as data_masked. Subsequently the masked data is averaged in xy yielding 
%   didv_avg.
 
% arguments
%   data            I(V) or didv sprectra of the grid, format: data(x,y,V)
%   masks            3D logical map of dimension xy matching data with z layers
%   returnNaNbool   0: data_masked is returned with zeros, 
%                   1: data_masked is returned with NaN. 

% returns 
%   didv_masked     masked didv data: NaN for all xy that were 0 in the mask 
%   avg_out         array of xy averaged values of didv_masked  
%   STD_out         standard veviation corresponding to avg_out
%   comment         for logging the function call

%   Rysa April 2025

arguments
    data
    masks            = ones(size(data, [1,2]))
    returnNaNbool   = 0
end

%catch specil expeption if [] is parsed as maks to edit 3rd argument
if isempty(masks)
    masks = ones(size(data, [1,2]));
end

%LOG comment of function call
comment = sprintf("avgMaskFast(didv:%s x %s x %s, mask:%s x %s x %s, returnNaNbool: %s)|", ...
    mat2str(size(data,1)), mat2str(size(data,2)), mat2str(size(data,3)), mat2str(size(masks, 1)), ...
    mat2str(size(masks, 2)), mat2str(size(masks, 3)), num2str(returnNaNbool));

%mask: 0 -> NaN
masks = double(masks);
masks(masks==0) = NaN;

avg_out = []; % initialize empty array
STD_out = [];


for i = 1:size(masks, 3)
    mask = masks(:,:,i);
    mask_expanded = repmat(mask, [1 1 size(data, 3)]);
    masked_data = data.*mask_expanded; % apply the mask
    avg = squeeze(mean(masked_data, [1 2], "omitnan")); 
    avg_out(:, i) = avg; % stack
    STD = squeeze(std(masked_data,0,[1,2],"omitnan"));
    STD_out(:, i) = STD; % stack
end

end