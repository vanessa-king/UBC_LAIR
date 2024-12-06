function [f, plot_name, saveFigPath, comment] = plot2DImage(LayoutCase, data, saveFigPath)
%This function plots a 2D Image of the data.
% LayoutCase will determin the format of the Image(grid or topo) this function generates.
% If you need a specific format for your Image, which is not already in
% setGraphLayout function, please add your format there. This way, your
% preferred formatting won't change anyone else's graph output. 

%Dong Chen 2024/??; M. Altthaler 2024/12

arguments
    LayoutCase      {mustBeText}        %string "gridsliceImage" or "topoImage"
    data                                %topo or grid slice
    saveFigPath     {mustBeText}=''     %string, optional input
end

    % conditional user propt to specify the folder to save the figure in
    if isempty(saveFigPath) 
        saveFigPath = uigetdir([],"Select a folder to save the figure");
    end
    % check if data is a 2D - matrix && and has non-zero dimensions
    if ismatrix(data) && all(size(data))
     f = figure();
     imagesc(permute(data,[2,1]));
     [ax] = setGraphLayout(LayoutCase);
    
     plot_name = uniqueNamePrompt(strcat(LayoutCase),"",saveFigPath);
     savefig(f, strcat(saveFigPath,"/",plot_name,".fig"))
     comment = sprintf(strcat("plot2DImage(datadimension=:%s), plotname=%s, savefigpath|"),mat2str(size(data)),plot_name, saveFigPath);
    else
        disp("Invalid dimensions of image. This function accepts only 2D data!");
    end

end