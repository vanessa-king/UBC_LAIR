function [figName, comment] = waterfallLinePlots(folder,data, V, mask, suppressSave, LayoutCase)
%Plot I(V) or dIdV(V) curves as a waterfall plot 
%   Plots all I(V) or dIdV(V) curves selected by the optional mask versus
%   the V axis in a waterfall plot. 

% M. Altthaler, March 2024

arguments
    %data and mask
    folder          {mustBeText}    %folder for data output (figure)
    data            {mustBeNumeric}  %I(V) or dIdV(V) data(x,y,V) in a 3D cube
    V               {mustBeNumeric}  %voltage axis V
    mask            {mustBeNumeric} = ones(size(data,[1,2])) %opt. mask
    suppressSave    {mustBeNumericOrLogical} = 0    %~=0 surpresses saving the plot
    % Define plot aesthetics
    LayoutCase      {mustBeText} = "3D_waterfall_dIdV" %layout case for the plot
end

%list of all x,y coordinates of 1's in the mask
if ismatrix(mask)
    if size(mask) == size(data,[1,2])
        [x,y] = find(mask);
    else
        disp("xy dimensons of the mask do not match the data")
        return
    end
else
    disp("Transparent plotting requires a 2D mask")
    return
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
% zlabel('dIdI (arb. u.)');
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