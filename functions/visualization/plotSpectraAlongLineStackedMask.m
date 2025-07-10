function  [fig, comment] = plotSpectraAlongLineStackedMask(avg, masks, V, plotError, numContLines)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    arguments (Input)
        avg         {mustBeNumeric} % avg(V,L)
        masks       {mustBeNumericOrLogical} % std(V,L)
        V           {mustBeNumeric} % V axis array of matching size
        plotError   {mustBeNumericOrLogical}    % plotError: 1 = yes, 0 = no
        numContLines{mustBeNumeric} = []    %optional input 
    end

    arguments (Output)
        fig
        comment
    end

    fig = figure('Name','2D plot: spectra vs. baseline');
    img = imagesc(1:size(avg,2),V,avg);
    colorbar;
    xlabel('Index of mask (bin) layer');
    ylabel('Bias Voltage (V)');
    title('Spectra Visualization');


    if plotError == 1 
        hold on
        if isempty(numContLines)
            numContLines = 20;
        end
        contLine = linspace(min(avg,[],'all'),max(avg,[],'all'),numContLines);
        [~,c] = contour(1:size(avg,2),V,avg,contLine);
        c.LineColor = 'r';
    end

    comment = 'plotSpectraAlongLineStackedMask()';

end