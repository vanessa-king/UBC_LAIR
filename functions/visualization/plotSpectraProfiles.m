function [figName, comment] = plotSpectraProfiles(data, V, avgData, step_size, numx, numy, LOGpath, LayoutCase)
%PLOTSPECTRAPROFILES Plots individual and average spectral profiles.
%   This function generates plots of individual and averaged spectral
%   profiles from the given data, saves the figure, and returns the 
%   filename and a comment for logging purposes.
%
%   data        3D matrix containing spectral data
%   V           Voltage values corresponding to the data points
%   avgData     Averaged spectral data
%   step_size   Step size for iterating over data points
%   numx        Number of points in the x-dimension of the data grid
%   numy        Number of points in the y-dimension of the data grid
%   LOGpath     Path for logging and saving the output figures
%   LayoutCase  Descriptive string for the layout configuration
%
% Returns:
%   figName     Name of the saved figure file
%   comment     Log comment summarizing the operation
%
% edited by James Day, July 2024

arguments
    data
    V
    avgData
    step_size {mustBeNumeric}
    numx {mustBeNumeric}
    numy {mustBeNumeric}
    LOGpath {mustBeText}
    LayoutCase {mustBeText}
end

% Define plot aesthetics
transp = 0.05;  % Transparency for individual spectra
lwidth1 = 1.5;  % Line width for individual spectra
lwidth2 = 2.5;  % Line width for average spectra
pcolorb_raw = [0, 0, 1]; % Blue color for individual traces
pcolorb_avg = [0, 0, 0]; % Black color for average data

% Prepare figure
f = figure;
hold on;

% Plot individual profiles
for i = 1:step_size:min(numx, size(data, 1))
    for j = 1:step_size:min(numy, size(data, 2))
        plotData = reshape(data(i, j, :), [], 1);
        if length(plotData) == length(V) % Ensuring vector lengths match
            plot(V, plotData, 'Color', [pcolorb_raw, transp], 'LineWidth', lwidth1);
        else
            disp('Warning: Vector lengths do not match, skipping plot for some indices.');
        end
    end
end

% Ensure avgData length matches V for plotting
if length(avgData) ~= length(V)
    avgData = interp1(1:length(avgData), avgData, linspace(1, length(avgData), length(V)), 'linear', 'extrap');
end

plot(V, avgData, 'Color', pcolorb_avg, 'LineWidth', lwidth2);  % Overlay average data

[ax] = setGraphLayout(LayoutCase);

% Saving the figure
figName = uniqueNamePrompt(strcat(LayoutCase, "_profile"), "", LOGpath);
savefig(f, fullfile(LOGpath, figName + ".fig"));

% Generating comment for logging
comment = sprintf("plotSpectraProfiles used for %s data. Step size: %d. plotname=%s|", LayoutCase, step_size, figName);

end