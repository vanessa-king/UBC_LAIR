function [dIdV, V_reduced, comment] = Derivative(I, V)
%This function generate a regular drivative data set, mostly used to
%calculated dI/dV. But it can be used for something else, e.g. dIdZ

%NOTE does not accept mask as partial dIdV calcualtion appears pointless
% calculate dIdV for the whole dataset and mask the relevant are in the
% dIdV for future processing. 

% M. Altthaler 2024/12;

%   Input:
%   I   this is a 3d array form (x, y, V)
%   V   this is a 1d array form (V, 1)

%   Output:
%   dIdV        this is a 3d array form (x, y, V-1)
%   V_reduced   this is a 1d array form (V-1, 1)

arguments
   I   % this is a 3d array form (x, y, V)                          
   V   % this is a 1d array form (V ,1)
end

comment = sprintf("Derivative(I:%s x %s x %s, V:%s)|", mat2str(size(I,1)), mat2str(size(I,2)), mat2str(size(I,3)), mat2str(size(V),1));

V_reduced = V(1:end-1); % purpose: while performing dI/dV the data size get reduced by 1. 
% You can change the reduced data point from the head or the tail. Here it's reduced from the tail.

% Compute the numerical derivative dI/dV
%dI(x,y,V), dV(1,1,V) match dim of dI and dV for trivial xy extension
dIdV = diff(I,1,3)./reshape(diff(V),1,1,[]);

end

