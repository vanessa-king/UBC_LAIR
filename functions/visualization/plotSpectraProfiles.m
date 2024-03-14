function [figName, comment] = plotSpectraProfiles(data, V, avgData, step_size, numx, numy, LOGpath, LayoutCase)
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

    [ax]=setGraphLayout(LayoutCase);

    % Saving the figure
    figName = uniqueNamePrompt(strcat(LayoutCase,"_profile"),"", LOGpath);
    savefig(f, fullfile(LOGpath, figName + ".fig"));

    % Generating comment for logging
    comment = sprintf("plotSpectraProfiles used for %s data. Step size: %d. plotname=%s|", LayoutCase, step_size, figName);
end