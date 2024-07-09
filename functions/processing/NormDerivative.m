function [norm_dIdV, I_corrected, V_reduced, I_offset, comment] = NormDerivative(I, V, C)
%Description: 
% This function generate a normalized dIdV data set, which requires an offset correction.

%   Input:
%   I   this is a 3d array form (x, y, V)
%   V   this is a 1d array form (V, 1)
%   C   this is a neumetic value to deal with the diverging value at V=0 while normalizing.

%   Output:
%   normdIdV    this is a 3d array form (x, y, V-1)
%   V_reduced   this is a 1d array form (V-1, 1)


arguments
    I
    V
    C    {mustBeFloat}
end

comment = sprintf("NormDerivative(I:%s,V:%s,C:%s)|", mat2str(size(I)), mat2str(size(V)),num2str(C));

V_reduced = V(1:end-1); % purpose: while performing dI/dV the data size get reduced by 1. 
% You can change the reduced data points from the head or the tail here.

% In any I-V curves, the current should be zero at bias=0 in most cases (there are some exceptions but rare). 
% However, the real data can have a systematic offset from the instrument. For example, bias output can have a very small 
% offset (i.e. the controller suppies some mV when the software is set to output 0 V. This can be
% corrected in the software by carefully checking the output. But if it wasn't corrected before the measurement 
% there could be an offset). For a proper calculation for a normalized didv this needs to be corrected. 
I_offset = NaN([size(I,1),size(I,2)]);
find(diff(sign(V))); 
[~,ind] = min(abs(V)); 
I_corrected = NaN(size(I)); 
for kx = 1:size(I,1) 
    for ky = 1:size(I,2) 
            I_corrected(kx,ky,:) = I(kx,ky,:)-I(kx,ky,ind); 
            I_offset(kx,ky) = I(kx,ky,ind);
    end
end

% Now calculate normalized didv: i.e. (dI/dV)/(I/V)
[dIdV_corrected, ~, ~] = Derivative(I_corrected,V);
norm_dIdV = NaN(size(I,1),size(I,2),length(V_reduced));
for kx = 1:size(I,1)
    for ky = 1:size(I,2)
        normtemp = sqrt((squeeze(I_corrected(kx,ky,1:length(V_reduced)))./V_reduced).^2+C^2);
        % Here if you do I_corrected(kx,ky,1:length(V_reduced)) has size [1, 1, 255]; V_reduced has size [255, 1].
        % This results in I_corrected(kx,ky,1:length(V_reduced))./V_reduced to have size [255, 1, 255], which is not what we want. 
        % squeeze(I_corrected(kx, ky, 1:length(V_reduced))) removes singleton dimensions, giving a vector of size [255, 1].
        % Then squeeze(I_corrected(kx,ky,1:length(V_reduced)))./V_reduced
        % returned a proper value, size of [255, 1]
        % C here is to deal with the diverging value at V=0 while normalizing.
        norm_dIdV(kx,ky,:) = reshape(squeeze(dIdV_corrected(kx,ky,:))./normtemp,1,1,[]);
        % For the same reason, this part also requires "squeeze" and
        % "reshape". Refer also "Derivative" function. 
    end
end