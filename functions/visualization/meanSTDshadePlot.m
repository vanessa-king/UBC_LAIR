function [figName,comment] = meanSTDshadePlot(folder, meanData, STDdata, xAxis, LayoutCase,STD_transp,STD_lwidth,mean_lwidth,STD_pcolorb,mean_pcolorb)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

arguments
    folder          {mustBeText}
    meanData        {mustBeNumeric}
    STDdata         {mustBeNumeric}
    xAxis           {mustBeNumeric}
    % Define plot aesthetics
    LayoutCase      {mustBeText} = "meanSTDshadedPlot"
    STD_transp      {mustBeNumeric} = 0.05;  % Transparency for shaded area
    STD_lwidth      {mustBeNumeric} = 1.0;  % Line width for +- STD
    mean_lwidth     {mustBeNumeric} = 2.5;  % Line width for mean spectra
    STD_pcolorb     {mustBeNumeric} = [1, 0, 0]; % red color for individual traces
    mean_pcolorb    {mustBeNumeric} = [0, 0, 0]; % Black color for average data
end

%call _helper function to plot (with suppressed prexeisting figure) to
%create the plot
[f,~] = meanSTDshadePlot_helper(meanData, STDdata, xAxis, 0, LayoutCase,STD_transp,STD_lwidth,mean_lwidth,STD_pcolorb,mean_pcolorb);

%graph layout 
[ax]=setGraphLayout(LayoutCase);

% Saving the figure
figName = uniqueNamePrompt(strcat(LayoutCase,"_profile"),"", folder);
savefig(f, fullfile(folder, figName + ".fig"));

% Generating comment for logging TBD!
comment = sprintf("[filename = %s] = meanSTDshadePlot(folder = %s, meanData, STDdata, xAxis, LayputCase = %s, STD_transp = %d, STD_lwidth = %d, mean_lwidth = %d, STD_pcolorb = [%d, %d, %d], mean_pcolorb = [%d, %d, %d])", figName, folder, LayoutCase,STD_transp,STD_lwidth,mean_lwidth,STD_pcolorb(1),STD_pcolorb(2),STD_pcolorb(3),mean_pcolorb(1),mean_pcolorb(2),mean_pcolorb(3));


end