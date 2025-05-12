function [figName, comment] = waterfallLinePlotsNew(folder, data, V, suppressSave, LayoutCase)
%Plot I(V) or dIdV(V) curves as a waterfall plot 
%   Plots all I(V) or dIdV(V) curves taken along a line. 

% M. Altthaler, March 2024, Jisun May, 2025

arguments
    folder          {mustBeText}    %folder for data output (figure)
    data            {mustBeNumeric}  %I(V) or dIdV(V) in 2D format
    V               {mustBeNumeric}  %voltage axis V
    suppressSave    {mustBeNumericOrLogical} = 0    %~=0 surpresses saving the plot
    % Define plot aesthetics
    LayoutCase      {mustBeText} = "3D_waterfall_dIdV" %layout case for the plot
end

%open figure
f = figure;
hold on;

%create a 2D Vmesh and stackLine
V = reshape(V, [],1);
[stackLine, Vmesh] = meshgrid(V,1:length(x));
%rearrange data in 2D (plane, i.e. all masked lines side by side)
dataPlane = zeros(size(Vmesh));
for n = 1:length(x)
    dataPlane(n,:) = data(x(n),y(n),:);
end
%waterfall plot
waterfall(Vmesh,stackLine,dataPlane);

%to be moved into a layout case once a 3D layout function is made
% xlabel('# of spectra');
% ylabel('Bias Voltage');
% zlabel('dIdV (arb. u.)');
% view(315, 45);
ax = set3DPlotLayout(LayoutCase);

if suppressSave==0
    % Saving the figure
    figName = uniqueNamePrompt(strcat(LayoutCase,"_plot"),"", folder);
    savefig(f, fullfile(folder, figName + ".fig"));
else
    figName = "NoFigSaved";
end

% Generating comment for logging TBD!
comment = sprintf("[figname = %s] = transparentLinePlot(folder = %s, data, V, mask, supSave = %d, LayoutCase = %s);|", figName, folder, suppressSave, LayoutCase);

end