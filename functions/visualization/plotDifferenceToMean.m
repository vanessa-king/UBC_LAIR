function [data_std, f, plot_name, savefigpath, comment] = plotDifferenceToMean(data, savefigpath)
%Description: 
% This function plots distribution of the average subtracted data and returns the standard deviation of it. 
%   Input
%   data: this is a 3d array form (x, y)
%   savefigpath: the path where you want to save the created figure from
%   this function. You can define the path by inputing directly in the function. If you don't
%   input the path but leave it empty, then browsing window will pop up for you to choose the folder. 

%   Output:
%   data_std    this is a 3d array form (x, y))
%   f 
%   plot_name
%   savefigpath: either the path you input into the function directly or
%   the selected folder from uigetdir input.


arguments
    data
    savefigpath    {mustBeText} ="" %string, optional input
end   

% When the savefigath is not specified, it will pop up a window for a user to select the folder where the figure is saved.
if savefigpath == ""
    savefigpath = uigetdir([],"Select a folder to save the figure");
end

data_difference= data - mean(data,"all");
    data_std=std(data_difference,[],'all');
    f = figure();
    mesh(data_difference)
    plot_name = uniqueNamePrompt("difference distribution","",savefigpath);
    title_string = sprintf("mean value: %s \x00B1 %s", num2str(mean(data,"all")),num2str(data_std));
    title(title_string)
    savefig(f, strcat(savefigpath,"/",plot_name,".fig"))

comment = sprintf("plotDifferenceToMean(data:%s, savefigpath:%s)|", mat2str(size(data)), savefigpath);
end

