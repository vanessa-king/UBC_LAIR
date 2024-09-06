function [f, plot_name, savefigpath, comment] = plot2DImage(LayoutCase, data, savefigpath)
%This function plots a 2D Image of the data.
% LayoutCase will determin the format of the Image(grid or topo) this function generates.
% If you need a specific format for your Image, which is not already in
% setGraphLayout function, please add your format there. This way, your
% preferred formatting won't change anyone else's graph output. 

 arguments
    LayoutCase  {mustBeText} %string "gridsliceImage" or "topoImage"
    data                    %topo or grid slice
    savefigpath     {mustBeText}="" %string, optional input
 end

% When the savefigath is not specified, it will pop up a window for a user to select the folder where the figure is saved.
if savefigpath == ""
    savefigpath = uigetdir([],"Select a folder to save the figure");
end

 f = figure();
 imagesc(data);
 [ax] = setGraphLayout(LayoutCase);

 plot_name = uniqueNamePrompt(strcat(LayoutCase),"",savefigpath);
 savefig(f, strcat(savefigpath,"/",plot_name,".fig"))
 comment = sprintf(strcat("plot2DImage(datadimension=:%s), plotname=%s, savefigpath|"),mat2str(size(data)),plot_name, savefigpath);
end