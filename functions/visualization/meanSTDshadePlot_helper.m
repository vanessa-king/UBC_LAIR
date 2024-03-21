function [f,comment] = meanSTDshadePlot_helper(meanData, STDdata, xAxis, preexFig, LayoutCase,STD_transp,STD_lwidth,mean_lwidth,STD_pcolorb,mean_pcolorb)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

arguments
    meanData        {mustBeNumeric}
    STDdata         {mustBeNumeric}
    xAxis           {mustBeNumeric}
    preexFig        {mustBeNumericOrLogical} = 0
    % Define plot aesthetics
    LayoutCase      {mustBeText} = "meanSTDshadedPlot"
    STD_transp      {mustBeNumeric} = 0.05;  % Transparency for shaded area
    STD_lwidth      {mustBeNumeric} = 1.0;  % Line width for +- STD
    mean_lwidth     {mustBeNumeric} = 2.5;  % Line width for mean spectra
    STD_pcolorb     {mustBeNumeric} = [1, 0, 0]; % red color for individual traces
    mean_pcolorb    {mustBeNumeric} = [0, 0, 0]; % Black color for average data
end

comment = sprintf("meanSTDshadePlot_helper(mean,STD,xAxis, %d,%s)",preexFig,LayoutCase);

if preexFig == 0 %makes a new figure unless surpressed
    f = figure();
    hold on
else %gets current figure -> when used to plot on top of other data
    f = gcf;
    hold on
end

%actual plotting 
%reshape xAxis, meanData, and STDdata and check their length
xAxis = reshape(xAxis, [], 1); %forces a col vector required for the patch!
STDdata = reshape(STDdata, [], 1); %see above
meanData = reshape(meanData, [], 1); %see above
if length(STDdata) == length(xAxis) && length(meanData) == length(xAxis)
    %plot STD lines and shaded area in between
    STD_upper = meanData+STDdata; 
    STD_lower = meanData-STDdata;
    plot(xAxis, STD_upper, 'Color', STD_pcolorb, 'LineWidth', STD_lwidth);
    plot(xAxis, STD_lower, 'Color', STD_pcolorb, 'LineWidth', STD_lwidth);
    
    %shaded area in between
    patch([xAxis; flipud(xAxis)],[STD_lower; flipud(STD_upper)],STD_pcolorb, 'FaceAlpha', STD_transp, 'EdgeColor', 'none');

    %plot mean data
    meanData = interp1(1:length(meanData), meanData, linspace(1, length(meanData), length(xAxis)), 'linear', 'extrap');
    plot(xAxis, meanData, 'Color', mean_pcolorb, 'LineWidth', mean_lwidth);  % Overlay average data
else
    disp('Warning: Vector lengths do not match, skipping plot of mean and STD data.');
end



end