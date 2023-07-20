%%   Description 
% This function generate normalized and smoothed(optional) didv data set(use it only when you want to normalize the data). 
%   Parameters 
%%  Input parameters: 
%   grid (1x1 structure): grid data as output from gridLoadData, 
%   C(float): normalization parameter , 
%   smooth(bool): True/False
%   normalize(bool): True/False
%%  Output parameters: 


function [didv, norm_didv, I_correction, V_reduced, I_offset, comment] = gridCorrectionNorm(grid, C, smooth, normalize)

arguments
    grid
    C    {mustBeFloat}
    smooth {mustBeNumericOrLogical}=0
    normalize {mustBeNumericOrLogical}=0
end


%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Never plot data (e.g. the whole gird) in the comment, only plot the values
%('=<VARn_value>') of variables that decide/affect how the function
%processes data (e.g. order of fit, ...) 
%Note convert all <VARn_value> to strings; 
comment = sprintf("gridCorrectionNorm(grid, C=%s, smooth=%s, normalize=%s)|", C, smooth, normalize);

%regular function processing:

% if smooth = False no smoothing before treating data 
% An example: gridCorrectionNorm(grid, 3E-10, 1), 1 means do the smooth part, if 0 means do not smooth current (or spatial)

V = grid.V; % pick array bias from grid 
I = grid.I; % pick array I from grid
V_reduced = V(1:end-1); % purpose: while performing dI/dV the data size get reduced by 1. You can change the reduced data points from the head or the tail here.  
I_offset = NaN([size(I,2),size(I,3)]);% purpose: if want normalize, this is the correction(constant offset) made to current. 
% correct for (I,V)=(0,V) % note that this is IV curve, when bias is zero, current should be zero. (basically, get rid of the offset)
% find the smallest bias and set that to zero
%=============================================

if find(diff(sign(V))) % This "if" statement looks for a sign change in V. 
    [~,ind] = min(abs(V)); %here only show the index position of the minimum value
    I_correction = NaN(size(I)); % build up a NaN matrix (201 120 120)
    for kx = 1:size(I,2) %here kx=1:120
        for ky = 1:size(I,3) %here ky=1:120
            I_correction(:,kx,ky) = I(:,kx,ky)-I(ind,kx,ky); %here to find the minimum array of V
            I_offset(kx,ky) = I(ind,kx,ky);
        end
    end
else

I_correction = I;

if smooth
    I_correction = smoothdata(I_correction, 1, 'gaussian', 10); % "10" here is the window size 
end

end
%Remark: the correction is for the normalization, note that in the normalization you are dividing didv to IV, which then the offset matters.
%=============================================

% differentiate and normalise the data
%=============================================
didv = NaN(length(V_reduced),size(I,2),size(I,3));
norm_didv = NaN(length(V_reduced),size(I,2),size(I,3));
%remark: after normalization, factor of transimission function is removed(especially useful for large range bias scan. e.g molecule) 

for kx = 1:size(I,2)
    for ky = 1:size(I,3)
        didv(:,kx,ky) = diff(I_correction(:,kx,ky))./diff(V); % just didv not normalised
        if normalize
        normtemp = sqrt((I_correction(1:length(V_reduced),kx,ky)./V_reduced).^2+C^2);
        % C here is to deal with the anamoly of V=0 while normalizing.
        norm_didv(:,kx,ky) = didv(:,kx,ky)./normtemp; % didv normalised
    end
end


end
%=============================================
%{
Comments from Feb.14
GridCornorm 
Jisun's question: 
machine have systematic offset (bias wise)
Could it be that the offset in bias created the offset in current
but if there is also offset in the current detection?
Then we can not correct it with software, we need to run the oscilloscope check. 

Comment closed.

May 5th
optimize the offset: 
output mean+- sigma
plot the value-mean, color map: threshold map: red-white-blue

%}


