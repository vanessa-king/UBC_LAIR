function [QPI, comment] = qpiCalculate(data)
%This function calculates the Quasiparticle Interference (QPI) patterns using
%Fourier transform of input data (typically dI/dV or Lockin dI/dV)
%
% Dong Chen 2025/04
%
%   Input:
%   data        this is a 3d array form (x, y, V)
%
%   Output:
%   QPI         this is a 3d array form (x, y, V) in the fourier domain 

arguments
    data        % this is a 3d array form (x, y, V)
end

comment = sprintf("qpiCalculate(data:%s x %s x %s)|", ...
    mat2str(size(data,1)), mat2str(size(data,2)), mat2str(size(data,3)));

% Get dimensions from input data
[x_num, y_num, points] = size(data);

% Initialize output array
QPI = zeros(x_num, y_num, points);

% Helper function to calculate QPI for a single slice
calculateQPI = @(slice) abs(fftshift(fft2(slice - mean(mean(slice)))));

% Calculate QPI
for i = 1:points
    QPI(:,:,i) = calculateQPI(data(:,:,i));
end

end
