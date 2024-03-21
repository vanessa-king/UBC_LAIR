function [figName,comment] = meanSTDshadePlot(folder, meanData, STDdata, xAxis, suppressSave,LayoutCase,STD_transp,STD_lwidth,mean_lwidth,STD_pcolorb,mean_pcolorb)
%Shaded plot of mean and standard deviation. 
%   Plots the mean, mean+STD, and mean-STD as lines vs. the xAxis. 
%   Additionally the STD is shaded. 

arguments
    folder          {mustBeText}
    meanData        {mustBeNumeric}
    STDdata         {mustBeNumeric}
    xAxis           {mustBeNumeric}
    suppressSave    {mustBeNumericOrLogical} = 0 %~=0 surpresses saving the plot 
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


if suppressSave==0
    % Saving the figure
    figName = uniqueNamePrompt(strcat(LayoutCase,"_profile"),"", folder);
    savefig(f, fullfile(folder, figName + ".fig"));
else
    figName = "NoFigSaved";
end


% Generating comment for logging TBD!
comment = sprintf("[filename = %s] = meanSTDshadePlot(folder = %s, meanData, STDdata, xAxis, LayputCase = %s, STD_transp = %d, STD_lwidth = %d, mean_lwidth = %d, STD_pcolorb = [%d, %d, %d], mean_pcolorb = [%d, %d, %d])", figName, folder, LayoutCase,STD_transp,STD_lwidth,mean_lwidth,STD_pcolorb(1),STD_pcolorb(2),STD_pcolorb(3),mean_pcolorb(1),mean_pcolorb(2),mean_pcolorb(3));


end