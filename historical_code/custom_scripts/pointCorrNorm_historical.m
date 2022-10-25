function [didv,norm_didv,iv,Vred] = pointCorrNorm(data, C, smooth)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

V = data.V;
Vred = data.V(1:end-1);
if smooth
    iv = smoothdata(data.iv, 1, 'gaussian', 10);
else
    iv = data.iv;
end


didv = diff(iv)./diff(V);

normtemp = sqrt( (iv(1:end-1)./Vred).^2 + C^2 );
norm_didv = didv./normtemp;

end

