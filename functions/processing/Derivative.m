function [dIdV, V_reduced, comment] = Derivative(I, V)
%This function generate a regular drivative data set, mostly used to
%calculated dI/dV. But it can be used for something else, e.g. dIdZ

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

comment = sprintf("Derivative(I:%s,V:%s)|", mat2str(size(I)), mat2str(size(V)));

V_reduced = V(1:end-1); % purpose: while performing dI/dV the data size get reduced by 1. 
% You can change the reduced data point from the head or the tail. Here it's reduced from the tail.


% Initialize dIdV array with NaN values
dIdV = NaN(size(I,1),size(I,2),length(V_reduced));

% Compute the numerical derivative dI/dV
for kx = 1:size(I,1)
    for ky = 1:size(I,2)
        dIdV(kx, ky, :) = reshape(diff(squeeze(I(kx, ky, :))) ./ diff(V), 1, 1, []);
        % Here if you do diff(I(kx,ky,:)) it has size [1, 1, 255]; diff(V) has size [255, 1].
        % This results in diff(I(kx,ky,:))./diff(V) to have size [255, 1, 255], which is not what we want. 
        % squeeze(I(kx, ky, :)) removes singleton dimensions, giving a vector of size [256, 1].
        % diff(squeeze(I(kx, ky, :))) returns a vector of size [255, 1].
        % Then diff(squeeze(I(kx,ky,:)))./diff(V) returns a vector of size [255 1]. 
        % To assign this result to dIdV(kx, ky, :) correctly, reshape(diff(squeeze(I(kx, ky, :))) ./ diff(V), 1, 1, []) 
        % ensures the result is reshaped to [1, 1, 255] before assigning it to dIdV(kx, ky, :).
    end
end



      
