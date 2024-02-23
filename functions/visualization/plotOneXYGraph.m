function [f, plot_name, comment] = plotOneXYGraph(LOGpath, LayoutCase, X, Y)
%This function plots a graph with one set of X and Y.
% LayoutCase will determin the format of the graph this function generates.
% If you need a specific format for your graph, which is not already in
% setGraphLayout function, please add your format there. This way, your
% preferred formatting won't change anyone else's graph output. 

 arguments
    LOGpath     {mustBeText} %string
    LayoutCase  {mustBeText} %string
    X
    Y    
 end

 f = figure();
 plot(X, Y);
 [ax] = setGraphLayout(LayoutCase);

 plot_name = uniqueNamePrompt(strcat("average_",LayoutCase),"",LOGpath);
 savefig(f, strcat(LOGpath,"/",plot_name,".fig"))
 comment = sprintf(strcat("plotOneXYGraph(",ax.XLabel.String,":%s, ",ax.YLabel.String,":%s), plotname=%s|"),mat2str(size(X)),mat2str(size(Y)),plot_name);
end