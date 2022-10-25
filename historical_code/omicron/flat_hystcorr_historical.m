function x_w = flat_hystcorr(x_m,fwbw)
%XW=FLAT_HYSTCORR(XM,FWBW)
%Transforms the measured coordinates of an axis XM into the "true" coordinates XW.
%
%FWBW=2 
%    selects a preset transformation for a trace
%FWBW=3 
%   selects a preset transformation for a retrace
%FWBW=[polynom with degree > 0] 
%   uses <polynom> as transfer function
%
%See also FLAT_TOOLBOX, POLYVAL

if(size(fwbw)==1),
    switch fwbw
    case 2
        warning('Please edit flat_hystcorr.m to enter the correction parameters for your experiment.');
        p=[1 0]; %unity transformation 
    case 3
        warning('Please edit flat_hystcorr.m to enter the correction parameters for your experiment.');
        p=[1 0]; %unity transformation 
    otherwise
        error('Please choose 2 (Trace), 3 (Retrace) or your own polynom as second parameter.');
    end
else
    p=fwbw;
end

x_w=polyval(p,x_m);

