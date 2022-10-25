function data = pointLoadData(fld,stamp_project,iv_nbr)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

iv_file = [stamp_project iv_nbr '.I(V)_flat'];

addpath(fld);

fiv = flat_parse(iv_file);
miv = flat2matrix(fiv);

rmpath(fld);

% select relevant information
Vraw = miv{2};
ivraw = miv{1};

% V sweeping check
if find(abs(diff(sign(diff(Vraw))))) % Checks if V is swept forwards and backwards
                                     % averages forwards and backwards
    NV = length(Vraw)/2;
    data.V = Vraw(1:NV);
    data.iv = (ivraw(1:NV)+flip(ivraw(NV+1:2*NV),1))/2; 
else
    data.V = Vraw;
    data.iv = ivraw;
end

% load offset data in corresponding image in nm
data.offset.x = 1e9*[fiv.offset.x]; 
data.offset.y = 1e9*[fiv.offset.y];

end

