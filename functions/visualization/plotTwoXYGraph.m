function [f, plot_name, savefigpath, comment] = plotTwoXYGraph(LayoutCase, X1, Y1, Y2, savefigpath, X2)
%This function plots a graph with two sets of X and Y. 
% LayoutCase will determin the format of the graph this function generates.
% If you need a specific format for your graph, which is not already in
% setGraphLayout function, please add your format there. This way, your
% preferred formatting won't change anyone else's graph output. By default,
% X1=X2 so it plots X, Y1, Y2 graph. If you need to plot two different sets
% of (X1, Y1) and (X2, Y2), you have an option to specify X2. 

 arguments
    LayoutCase  {mustBeText} %string
    X1
    Y1
    Y2
    savefigpath {mustBeText} ="" %string, optional input
    X2 = X1 %optional input
 end

% Ensure X1, Y1, X2, and Y2 are vectors of compatible sizes
if ~isvector(X1) || ~isvector(Y1) || ~isvector(X2) || ~isvector(Y2)
    error('All inputs X1, Y1, X2, and Y2 must be vectors.');
end
if numel(X1) ~= numel(Y1)
    error('X1 and Y1 must have the same number of elements.');
end
if numel(X2) ~= numel(Y2)
    error('X2 and Y2 must have the same number of elements.');
end

% When the savefigath is not specified, it will pop up a window for a user to select the folder where the figure is saved.
if savefigpath == ""
    savefigpath = uigetdir([],"Select a folder to save the figure");
end

% Create the figure and plot
 f = figure();
 plot(X1, Y1);
 hold on;
 plot(X2, Y2);
 [ax] = setGraphLayout(LayoutCase);

 plot_name = uniqueNamePrompt(strcat("average_",LayoutCase),"",savefigpath);
 savefig(f, strcat(savefigpath,"/",plot_name,".fig"))
 
 % Include details in the comment output 
 if isequal(X1, X2)
    comment = sprintf("plotTwoXYGraph(%s:%s, %s:%s, Y2:%s), plotname=%s, savefigpath=%s", ...
                      ax.XLabel.String, mat2str(size(X1)), ...
                      strcat(ax.YLabel.String, "Y1"), mat2str(size(Y1)), ...
                      mat2str(size(Y2)), plot_name, savefigpath);
 else
    comment = sprintf("plotTwoXYGraph(%s:%s, %s:%s, Y2:%s, X2:%s), plotname=%s, savefigpath=%s", ...
                      ax.XLabel.String, mat2str(size(X1)), ...
                      strcat(ax.YLabel.String, "Y1"), mat2str(size(Y1)), ...
                      mat2str(size(Y2)), mat2str(size(X2)), plot_name, savefigpath);
end