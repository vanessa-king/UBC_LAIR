folder = 'C:\Users\MarkusAdmin\OneDrive - UBC\MatlabProgramming';

load('dIdV_V_test_data.mat');
data = dIdV;
V = V_reduced;


[mask,comment] = MaskSparseGrid(size(data,[1,2]),5,5);
[figName, comment] = waterfallLinePlots(folder,data, V,mask);