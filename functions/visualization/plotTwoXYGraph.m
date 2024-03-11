function [f, plot_name, comment] = plotTwoXYGraph(LOGpath, LayoutCase, X1, Y1, Y2, X2)
%This function plots a graph with two sets of X and Y. 
% LayoutCase will determin the format of the graph this function generates.
% If you need a specific format for your graph, which is not already in
% setGraphLayout function, please add your format there. This way, your
% preferred formatting won't change anyone else's graph output. By default,
% X1=X2 so it plots X, Y1, Y2 graph. If you need to plot two different sets
% of (X1, Y1) and (X2, Y2), you have an option to specify X2. 

 arguments
    LOGpath     {mustBeText} %string
    LayoutCase  {mustBeText} %string
    X1
    Y1
    Y2
    X2 = X1
 end

 f = figure();
 plot(X1, Y1);
 hold on;
 plot(X2, Y2);
 [ax] = setGraphLayout(LayoutCase);

 plot_name = uniqueNamePrompt(strcat("average_",LayoutCase),"",LOGpath);
 savefig(f, strcat(LOGpath,"/",plot_name,".fig"))
 comment = sprintf(strcat("plotTwoXYGraph(",ax.XLabel.String,":%s, ",strcat(ax.YLabel.String,"Y1"),":%s, ","Y2",":%s), ","plotname=%s|"),mat2str(size(X1)),mat2str(size(Y1)),mat2str(size(Y2)),plot_name);
end