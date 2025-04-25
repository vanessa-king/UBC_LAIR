function [f, plot_name, saveFigPath, comment] = plot2DImage(LayoutCase, data, saveFigPath, n, V_reduced, imageV)
%This function plots a 2D Image of the data.
% LayoutCase will determin the format of the Image(grid or topo) this function generates.
% If you need a specific format for your Image, which is not already in
% setGraphLayout function, please add your format there. This way, your
% preferred formatting won't change anyone else's graph output. 

%Dong Chen 2024/??; M. Altthaler 2024/12; Jisun 2025/4

arguments
    LayoutCase      {mustBeText}        %string "gridsliceImage" or "topoImage"
    data                                %topo or grid slice
    saveFigPath     {mustBeText}=''     %string, optional input
    n           {mustBePositive} = []   % optional, only for 3D data
    V_reduced   {mustBeNumeric} = []    % optional, only for 3D data
    imageV      {mustBeNumeric} = []    % optional, only for 3D data
end
    % Check if data is 2D or 3D
    [data_slice, imN, V_actual] = dataSlice2D(data,n,V_reduced,imageV);
   
    % conditional user propt to specify the folder to save the figure in
    if isempty(saveFigPath) 
        saveFigPath = uigetdir([],"Select a folder to save the figure");
    end
    % plot image of data slice
    f = figure();   
    imagesc(data_slice');
    setGraphLayout(LayoutCase);
    plot_name = uniqueNamePrompt(strcat(LayoutCase),"",saveFigPath);
    savefig(f, strcat(saveFigPath,"/",plot_name,".fig"))
    comment = sprintf("plot2DImage(data(:,:,imN = %s | V_actual = %s), V_reduced, imageV =%s, plotname=%s, savefigpath=%s|", num2str(imN),num2str(V_actual), num2str(imageV),plot_name, saveFigPath);
end