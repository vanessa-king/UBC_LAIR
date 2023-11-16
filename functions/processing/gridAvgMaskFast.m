function [data_masked, didv_avg, comment] = gridAvgMaskFast(data, mask)
% averaging I(V) or dIdV data in x and y for the area determined by the mask
%   The function takes I(V) or dIdV data of the format data(I,x,y) and
%   applies the mask of corresponding size xy to the data, which is returend 
%   as data_masked. Subsequently the masked data is averaged in xy yielding 
%   didv_avg.
 
% arguments
%   data    I(V) or didv sprectra of the grid, format: data(I,x,y)
%   mask    2D logical map of dimension xy matching data

% returns 
%   didv_masked     masked didv data: 0 for all xy that were 0 in the mask 
%   didv_avg        array of xy averaged values of didv_masked  
%   comment         for logging the function call

%   Nov. 2023 - Markus Altthaler

arguments
    data
    mask
end

%LOG comment of function call
comment = sprintf("gridAvgMask(didv:%s, mask:%s)|", mat2str(size(data)), mat2str(size(mask)));

% data(I,x,y) -> data(x,y,I)
data_masked = permute(data,[ 2 3 1 ]); 

%apply mask
data_masked = data_masked.*mask;

%data(x,y,I) -> data(I,x,y)
data_masked = permute(data_masked, [3 1 2]);

%number of points per xy layer based on mask
numPoints = sum(mask(:));

%average: sum of all (= sum on nonzero elements per xy layer) divided by number of non zero points
didv_avg = sum(data_masked, [2 3])./numPoints;
