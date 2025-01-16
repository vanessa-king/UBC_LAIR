function [f, plot_name, savefigpath, comment] = plotOneXYGraph(LayoutCase, X, Y, Yerr, savefigpath)
%This function plots a graph with one set of X and Y.
% LayoutCase will determine the format of the graph this function generates.
% If you need a specific format for your graph, which is not already in
% setGraphLayout function, please add your format there. This way, your
% preferred formatting won't change anyone else's graph output. 

% edited by: Rysa jan 2025
 arguments
    LayoutCase  {mustBeText} %string
    X
    Y
    Yerr                    % Y uncertainty
    savefigpath     {mustBeText}="" %string, optional input
 end

% Ensure X and Y are vectors of compatible sizes
if ~isvector(X) || ~isvector(Y)
    error('Inputs X and Y must be vectors.');
end
if numel(X) ~= numel(Y)
    error('X and Y must have the same number of elements.');
end

% When the savefigath is not specified, it will pop up a window for a user to select the folder where the figure is saved.
if savefigpath == ""
    savefigpath = uigetdir([],"Select a folder to save the figure");
end

if isempty(Yerr)
    f = figure();
    plot(X, Y);

else
    f=figure();
    errorbar(X, Y, Yerr);
end

[ax] = setGraphLayout(LayoutCase);

 plot_name = uniqueNamePrompt(strcat("average_",LayoutCase),"",savefigpath);
 savefig(f, strcat(savefigpath,"/",plot_name,".fig"))
 comment = sprintf("plotOneXYGraph(%s:%s, %s:%s), plotname=%s, savefigpath=%s", ...
                  ax.XLabel.String, mat2str(size(X)), ...
                  ax.YLabel.String, mat2str(size(Y)), ...
                  plot_name, savefigpath);
end