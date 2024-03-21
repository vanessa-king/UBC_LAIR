function [figName, comment] = transparentMeanSTDplot(folder,data, V, mask, supressSave,LayoutCase,transp_transp,transp_lwidth,transp_color,STD_transp,STD_lwidth,mean_lwidth,STD_pcolorb,mean_pcolorb)
%Plots all dIdV cuves transparent with the average +- STD on top
%   Plots the raw spectra [e.g. I(V), dIdV(I)] as selected by the mask 
%   versus V. calculates the average of the masked data and STD and plots 
%   those on top with a shaded area from mean+STD to mean-STD.

%   M. Altthaler, March 2024

arguments
    %data and mask
    folder          {mustBeText}    %folder for data output (figure)
    data            {mustBeNumeric}  %I(V) or dIdV(V) data(x,y,V) in a 3D cube
    V               {mustBeNumeric}  %voltage axis V
    mask            {mustBeNumeric} = ones(size(data,[1,2])) %opt. mask
    supressSave     {mustBeNumericOrLogical} = 0  %~=0 surpresses saving the plot 
    % Define plot aesthetics
    LayoutCase      {mustBeText} = "transparent_dIdV" %layout case for the plot
    %transparent lines plot parameters 
    transp_transp   {mustBeNumeric} = 0.05 %transparent lines transparency parameter 
    transp_lwidth   {mustBeNumeric} = 1.5 %transparent lines linewidth
    transp_color    {mustBeNumeric} = [0, 0, 1] %transparent lines color
    %meanSTD plot parameters
    STD_transp      {mustBeNumeric} = 0.05 %transparency STD shaded area
    STD_lwidth      {mustBeNumeric} = 1.0 %linewidth of the mean +- STD lines 
    mean_lwidth     {mustBeNumeric} = 2.5 %linewidth of the mean line
    STD_pcolorb     {mustBeNumeric} = [1, 0, 0] %color of STD lines and color*transparency for shaded area
    mean_pcolorb    {mustBeNumeric} = [0, 0, 0] %colro of the mean line

end

%calcualte average and STD from masked data
[meanData,STDdata,comment] = xyPlanarMeanSTD(data,mask);

%transparent line plots using transparentLinePlot(...,supSave=1,...)
[~, comment] = transparentLinePlot(folder,data, V, mask,[],1,LayoutCase,transp_transp,transp_lwidth,[],transp_color);

%plot average and STD on top
[f,comment] = meanSTDshadePlot_helper(meanData, STDdata, V, 1,LayoutCase,STD_transp,STD_lwidth,mean_lwidth,STD_pcolorb,mean_pcolorb);

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
comment = sprintf("[figname = %s]=transparentLinePlot(folder = %s, data, V, mask, LayoutCase = %s, transp_transp = %d, transp_lwidth = %d, transp_color = [%d, %d, %d], STD_transp = %d, STD_lwidth = %d, mean_lwidth = %d, STD_pcolorb = [%d, %d, %d], mean_pcolorb = [%d, %d, %d]);", figName, folder, LayoutCase,transp_transp,transp_lwidth,transp_color(1),transp_color(2),transp_color(3),STD_transp,STD_lwidth,mean_lwidth,STD_pcolorb(1),STD_pcolorb(2),STD_pcolorb(3),mean_pcolorb(1),mean_pcolorb(2),mean_pcolorb(3));

end