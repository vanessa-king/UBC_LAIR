function [smoothed_data, comment] = smoothData(data, span, type, method)
%GRIDSMOOTH Applies moving-average smoothing on data.
%   It needs to be an odd integer. Deafult is 3 (nearest neighbor
%   averaging) but you can use 5 for next nearest neighbor averaging. Or
%   higher, if necessary. 

%   data        data to be smoothed, a 3D matrix of format data(x,y,V)
%   span        size of the window applyed for smooting. Must be odd (will be reduced by 1 or even values) 
%   type        'IV':   applies smoothing to 3rd dim (i.e. V) [default: 'IV']
%               'topo': applies smoothing to 1st and 2nd dim (i.e. xy)
%   method      'box' or 'gaussian' (ref. doc. smooth3), [default: 'box']

% M. Altthaler, April 2024; edited M. Altthaler 2024/12

arguments
   data                             
   span         {mustBeNumeric}=3   
   type         {mustBeText}='IV'   % 
   method       {mustBeText}='box'  %'box' or 'gaussian' (ref. doc. smooth3)
end

% enforce odd window size
if mod(span,2) ~= 1
    span = span -1;
end
% Generate the comment
comment = sprintf("gridsmooth(data, span =  %d, type = %s, method = %s)|",span ,type , method);

switch type
    case 'IV'
        smoothed_data = smooth3(data,method,[1,1,span]);
    case 'topo'
        smoothed_data = smooth3(data,method,[span,span,1]);
    otherwise
        disp("Invalid type: choose IV or topo");
end
 
end