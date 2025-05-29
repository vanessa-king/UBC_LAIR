function cmap = invgray(n)
% INVERSE_GRAY Inverse grayscale colormap
%   INVERSE_GRAY returns an inverse grayscale colormap with 256 levels.
%   INVERSE_GRAY(N) returns an N-by-3 matrix containing an inverse grayscale colormap.
%   The colormap ranges from white to black, opposite of MATLAB's default gray colormap.
%
%   Example:
%       imagesc(peaks)
%       colormap(inverse_gray)
%       colorbar
%
%   See also GRAY, COLORMAP, RGBPLOT.
%
%   Created: March 2024

% Handle input arguments
if nargin < 1
    n = 256;
end

% Create the inverse grayscale colormap
% Start with white (1,1,1) and go to black (0,0,0)
cmap = linspace(1, 0, n)';
cmap = [cmap cmap cmap];

% Ensure the output is in the correct range
cmap = max(0, min(1, cmap));

end 