%Description: 
% This function plots distribution of the average subtracted data and returns the standard deviation of it. 
function [data_std, f, plot_name, comment] = plotDifferenceToMean(data, path)   

comment = sprintf("plotDifferenceToMean(data:%s)|", mat2str(size(data)));

data_difference= data - mean(data,"all");
    data_std=std(data_difference,[],'all');
    f = figure();
    mesh(data_difference)
    plot_name = uniqueNamePrompt("difference distribution","",path);
    title_string = sprintf("mean value: %s \x00B1 %s", num2str(mean(data,"all")),num2str(data_std));
    title(title_string)
    savefig(f, strcat(path,"/",plot_name,".fig"))
end

