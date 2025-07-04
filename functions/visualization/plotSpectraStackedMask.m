function [fig, comment] = plotSpectraStackedMask(avg, std, V, plotError)
    %UNTITLED4 Summary of this function goes here
    %   Detailed explanation goes here
    
    % created M. Altthaler 07/2025
    
    arguments (Input)
        avg         {mustBeNumeric} % avg(V,L)
        std         {mustBeNumeric} % std(V,L)
        V           {mustBeNumeric} % V axis array of matching size
        plotError   {mustBeNumericOrLogical}    % plotError: 1 = yes, 0 = no
    end
    
    arguments (Output)
        fig
        comment
    end
    
    %bulk treatment
    fig = figure('Name','Stacked Mask spectra plot:');
    
    % Create a stacked plot based on the specified plot case
    hold on;
    for i = 1:size(avg, 2)
        % Plot the average spectrum
        hPlot = plot(V, avg(:, i), 'DisplayName', sprintf('Avg %d', i), 'LineWidth',1.5);
        if plotError == 1
            % Get the color used in the plot
            plotColor = hPlot.Color;  % Retrieve the color of the plot
        
            % Prepare x and y coordinates for fill
            xCoords = [V; flipud(V)];
            yCoords = [avg(:, i) + std(:, i); flipud(avg(:, i) - std(:, i))];
        
            % Fill the area with the same color as the plot
            fill(xCoords, yCoords, plotColor, 'FaceAlpha', 0.1, 'EdgeColor', 'none',  'DisplayName', '');  % Empty DisplayName to exclude from legend
        end
    end
    hold off;
    legend show;
    setGraphLayout('IV');

    comment = "plotSpectraStackedMask(avg, std, V, plotError)";

end