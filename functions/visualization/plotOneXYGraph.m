function [f, plot_name, savefigpath, comment] = plotOneXYGraph(LayoutCase, X, Y, savefigpath)
%This function plots a graph with one set of X and Y.
% LayoutCase will determin the format of the graph this function generates.
% If you need a specific format for your graph, which is not already in
% setGraphLayout function, please add your format there. This way, your
% preferred formatting won't change anyone else's graph output. 

 arguments
    LayoutCase  {mustBeText} %string
    X
    Y
    savefigpath     {mustBeText}="" %string, optional input
 end

% When the savefigath is not specified, it will pop up a window for a user to select the folder where the figure is saved.
if savefigpath == ""
    savefigpath = uigetdir([],"Select a folder to save the figure");
end

 f = figure();
 plot(X, Y);
 [ax] = setGraphLayout(LayoutCase);

 plot_name = uniqueNamePrompt(strcat("average_",LayoutCase),"",savefigpath);
 savefig(f, strcat(savefigpath,"/",plot_name,".fig"))
 comment = sprintf(strcat("plotOneXYGraph(",ax.XLabel.String,":%s, ",ax.YLabel.String,":%s), plotname=%s, savefigpath|"),mat2str(size(X)),mat2str(size(Y)),plot_name, savefigpath);
end