%   Description 
% This function generate normalized and smoothed(optional) didv data set that have v=0 as the smallest absolute bias. 
%   Parameters 
%%  Input parameters: grid(3d array): grid data, C(float): normalization parameter , smooth(bool): True/False


function [didv, norm_didv, I_correction, V_reduced] = gridCorrectionNorm(grid, C, smooth)
 
% if smooth = False no smoothing before treating data 
% An example: gridCorrectionNorm(grid, 3E-10, 1) 0 means do not smooth current (or spatial); 1 means do the smooth part

V = grid.V; % pick array bias from grid 
I = grid.I; % pick array iv from grid
V_reduced = V(1:end-1); % purpose: while performing dI/dV the data size get reduced by 1. You can change the reduced data points from the head or the tail here.  

% correct for (I,V)=(0,V) % note that this is IV curve, when bias is zero, current should be zero. (basically, get rid of the offset)
% find the smallest bias and set that to zero
%=============================================
%{
if find(diff(sign(V))) % This "if" statement looks for a sign change in V. 
    [~,ind] = min(abs(V)); %here only show the index position of the minimum value
    I_correction = NaN(size(I)); % build up a NaN matrix (201 120 120)
     for kx = 1:size(I,2) %here kx=1:120
        for ky = 1:size(I,3) %here ky=1:120
            I_correction(:,kx,ky) = I(:,kx,ky)-I(ind,kx,ky); %here to find the minimum array of V
        end
    end
else

I_correction = I

if smooth
    I_correction = smoothdata(I_correction, 1, 'gaussian', 10); % "10" here is the window size 
end
%=============================================

% differentiate and normalise the data
%=============================================
didv = NaN(length(V_reduced),size(I,2),size(I,3));
norm_didv = NaN(length(V_reduced),size(I,2),size(I,3));
%remark: after normalization, factor of transimission function is removed(especially useful for large range bias scan. e.g molecule) 

for kx = 1:size(I,2)
    for ky = 1:size(I,3)
        didv(:,kx,ky) = diff(I_correction(:,kx,ky))./diff(V); % just didv not normalised
        normtemp = sqrt((I_correction(1:length(V_reduced),kx,ky)./V_reduced).^2+C^2);
        % C here is to deal with the anamoly of V=0 while normalizing.
        norm_didv(:,kx,ky) = didv(:,kx,ky)./normtemp; % didv normalised
    end
end


end
%=============================================

Comments from Feb.14
GridCornorm 
Jisun's question: 
machine have systematic offset (bias wise)
Could it be that the offset in bias created the offset in current
but if there is also offset in the current detection?
Then we can not correct it with software, we need to run the oscilloscope check. 

target: print offset, do it or not. manually input the offset(optional).


