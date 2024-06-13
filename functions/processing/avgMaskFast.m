function [data_masked, didv_avg, comment] = avgMaskFast(data, mask)
% averaging I(V) or dIdV data in x and y for the area determined by the mask
%   The function takes I(V) or dIdV data of the format data(x,y,V) and
%   applies the mask of corresponding size xy to the data, which is returend 
%   as data_masked. Subsequently the masked data is averaged in xy yielding 
%   didv_avg.
 
% arguments
%   data    I(V) or didv sprectra of the grid, format: data(x,y,V)
%   mask    2D logical map of dimension xy matching data

% returns 
%   didv_masked     masked didv data: NaN for all xy that were 0 in the mask 
%   didv_avg        array of xy averaged values of didv_masked  
%   comment         for logging the function call

%   Nov. 2023 - Markus Altthaler, June 2024 - M. Altthaler

arguments
    data
    mask = ones(size(data, [1,2]))
end

%LOG comment of function call
comment = sprintf("avgMaskFast(didv:%s x %s x %s, mask:%s x %s)|", mat2str(size(data),1), mat2str(size(data),2), mat2str(size(data),3), mat2str(size(mask), 1), mat2str(size(mask), 2));


%mask: 0 -> NaN
mask(mask==0) = NaN;

%applying mask to data (triv. extendsion in 3rd dim applies) 
data_masked = data.*mask;

%averaging
didv_avg = mean(data_masked,[1,2],"omitnan");
%dimensions: 1x1xn -> nx1 
didv_avg = squeeze(didv_avg);

%data_masked NaN->0 (optional if we prefer that)
%data_masked(isnan(data_masked)) = 0; 