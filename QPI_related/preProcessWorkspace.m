function [midV, I, LockindIdV, dIdV, QPI, LockinQPI, comment] = preProcessWorkspace(data, sigma, apply_smoothing)
%PREPROCESSWORKSPACE Preprocesses workspace data for QPI analysis and performs Fourier transforms.
%   This function processes the input grid data for QPI analysis, including
%   Gaussian smoothing of the current and lock-in data, numerical differentiation,
%   and Fourier transformation of the processed data.
%
% Inputs:
%   data            - Struct containing grid data (including current and lock-in data).
%   sigma           - Standard deviation for Gaussian smoothing (numeric).
%   apply_smoothing - Boolean to determine if Gaussian smoothing should be applied.
%
% Outputs:
%   midV            - Midpoint voltages calculated from the data.
%   I               - Processed current data, optionally smoothed.
%   LockindIdV      - Processed lock-in data, optionally smoothed.
%   dIdV            - Numerically differentiated current data.
%   QPI             - Fourier transform of dI/dV data.
%   LockinQPI       - Fourier transform of Lock-in dI/dV data (if available).
%   comment         - Log comment describing the preprocessing steps.
%
% Example:
%   [midV, I, LockindIdV, dIdV, QPI, LockinQPI] = preProcessWorkspace(data, 2, true);
%
% Author:
%   Your Name, Date

% Input argument validation
arguments
    data
    sigma {mustBeNumeric}
    apply_smoothing 
end

% Extract dimensions and current data from input
x_num = data.grid.header.grid_dim(1);
y_num = data.grid.header.grid_dim(2);
points = data.grid.header.points;
I = data.grid.I;

% Calculate midpoint voltages to align with differentiated data
midV = zeros(size(data.grid.V, 1) - 1, 1);
for i = 1:size(data.grid.V, 1) - 1
    midV(i, 1) = data.grid.V(i, 1) + (data.grid.V(i + 1, 1) - data.grid.V(i, 1)) / 2;
end

% Apply Gaussian smoothing to the current data if requested
if apply_smoothing
    fprintf('Smoothing current data \n');
    for i = 1:x_num
        for j = 1:y_num
            I(i, j, :) = gaussfilter1d(I(i, j, :), sigma);
        end
    end
else
    fprintf('Skipping Gaussian smoothing of current data \n');
end

% Process lock-in data if available
if isfield(data.grid, 'lock_in')
    fprintf('Acquiring Lock-in data \n');
    lock_in = data.grid.lock_in;
    LockindIdV = zeros(x_num, y_num, points);
    if apply_smoothing
        fprintf('Applying Gaussian smoothing to Lock-in data \n');
        for i = 1:x_num
            for j = 1:y_num
                LockindIdV(i, j, :) = gaussfilter1d(lock_in(i, j, :), sigma);
            end
        end
    else
        LockindIdV = lock_in;
    end
else
    fprintf('No Lock-in data found. Skipping Lock-in processing. \n');
    LockindIdV = [];
end

% Numerically differentiate the current data to obtain dI/dV
fprintf('Differentiating current \n');
V_step = midV(2) - midV(1);
dIdV = (I(:, :, 2:end) - I(:, :, 1:end-1)) / V_step;

% Perform Fourier transform on dI/dV data
fprintf('Fourier transforming dI/dV \n');
QPI = zeros(x_num, y_num, points - 1);
for i = 1:(points - 1)
    QPI(:, :, i) = abs(fftshift(fft2(dIdV(:, :, i) - mean(mean(dIdV(:, :, i))))));
end

% Perform Fourier transform on Lock-in dI/dV data if available
if ~isempty(LockindIdV)
    fprintf('Fourier transforming Lock-in dI/dV \n');
    LockinQPI = zeros(x_num, y_num, points);
    for i = 1:points
        LockinQPI(:, :, i) = abs(fftshift(fft2(LockindIdV(:, :, i) - mean(mean(LockindIdV(:, :, i))))));
    end
else
    LockinQPI = [];
end

% Generate comment log
comment = sprintf('preProcessWorkspace with smoothing: %d, sigma: %.2f, data size: [%d, %d, %d]', ...
    apply_smoothing, sigma, x_num, y_num, points);

fprintf('Finished preprocessing and Fourier transforms! \n');

end
