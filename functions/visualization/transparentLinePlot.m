function [figName, comment] = transparentLinePlot(folder,data, V, mask, avgData, suppressSave, LayoutCase,transp,lwidth1,lwidth2,pcolorb_raw,pcolorb_avg)
%Plot I(V) or dIdV(V) curves transparent and an optional average on top 
%   Plots all I(V) or dIdV(V) curves selected by the optional mask versus
%   the V axis in semi transparent blue. If avgData is parsed a thicker
%   black line thereof is plotted on top. The following optional arguments
%   are used to alter the appearance of the plot. See arguments block for
%   details. 

% M. Altthaler, March 2024

arguments
    %data and mask
    folder          {mustBeText}    %folder for data output (figure)
    data            {mustBeNumeric}  %I(V) or dIdV(V) data(x,y,V) in a 3D cube
    V               {mustBeNumeric}  %voltage axis V
    mask            {mustBeNumericOrLogical} = ones(size(data,[1,2])) %opt. mask
    avgData         {mustBeNumeric} = [] %opt. average to be plotted
    suppressSave    {mustBeNumericOrLogical} = 0    %~=0 surpresses saving the plot
    % Define plot aesthetics
    LayoutCase      {mustBeText} = "transparent_dIdV" %layout case for the plot
    transp          {mustBeNumeric} = 0.05;  % Transparency for individual spectra
    lwidth1         {mustBeNumeric} = 1.5;  % Line width for individual spectra
    lwidth2         {mustBeNumeric} = 2.5;  % Line width for average spectra
    pcolorb_raw     {mustBeNumeric} = [0, 0, 1]; % Blue color for individual traces
    pcolorb_avg     {mustBeNumeric} = [0, 0, 0]; % Black color for average data
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

%plot individual spectra as masked
V = reshape(V, [],1);

for n=1:length(x)
    plotData = reshape(data(x(n), y(n), :), [], 1);
    if length(plotData) == length(V) % Ensuring vector lengths match
        plot(V, plotData, 'Color', [pcolorb_raw, transp], 'LineWidth', lwidth1);
    else
        msg = sprintf("Warning: Vector lengths do not match, skipping plot for indices [x,y] = [%d,%d] \n",x,y);
        disp(msg);
    end
end

%plot average line if parsed
if ~isempty(avgData)
    % Ensure avgData length matches V for plotting
    avgData = reshape(avgData, [], 1);
    if length(avgData) == length(V)
        avgData = interp1(1:length(avgData), avgData, linspace(1, length(avgData), length(V)), 'linear', 'extrap');
        plot(V, avgData, 'Color', pcolorb_avg, 'LineWidth', lwidth2);  % Overlay average data
    else
        disp('Warning: Vector lengths do not match, skipping plot of average data.');
    end
end

%graph layout
[ax]=setGraphLayout(LayoutCase);

if suppressSave==0 %safe figure unless supSave is parsed ~=0 
    % Saving the figure
    figName = uniqueNamePrompt(strcat(LayoutCase,"_profile"),"", folder);
    savefig(f, fullfile(folder, figName + ".fig"));
else
    figName = "NoFigSaved";
end   
% Generating comment for logging TBD!
comment = sprintf("[filename = %s] = transparentLinePlot(folder = %s, data, V, mask, avgData, supSave = %d, LayputCase = %s, transp = %d, lwidth1 = %d, lwidth2 = %d, pcolorb_raw = [%d, %d, %d], pcolorb_avg = [%d, %d, %d])", figName, folder,suppressSave, LayoutCase,transp,lwidth1,lwidth2,pcolorb_raw(1),pcolorb_raw(2),pcolorb_raw(3),pcolorb_avg(1),pcolorb_avg(2),pcolorb_avg(3));

end