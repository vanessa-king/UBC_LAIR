folder = 'C:\Users\MarkusAdmin\OneDrive - UBC\MatlabProgramming';

load('dIdV_V_test_data.mat');
data = dIdV;
V = V_reduced;

%masking
[mask,comment] = MaskSparseGrid(size(data,[1,2]),4,4);
%calculating mean (average) 
[mean_out,STD_out,comment] = xyPlanarMeanSTD(data,mask);
%plotting masked raw data and mean
[figName, comment] = transparentLinePlot(folder,data, V, mask,mean_out);

%means STD plot
[figureName,comment] = meanSTDshadePlot(folder, mean_out, STD_out, V);

%opt. 3D masking (not relevant here)
%[mask,comment] = MaskSparse3DGrid(size(data,[1,2,3]),1,1,2,5,5,6);