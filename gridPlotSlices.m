%        Description
% This function makes dIdV slice at a given bias. 
%        Parameters
% IVdata: 3D arrary(x*y*energy), Raw IV data
% V: Vector, the meaured biases of the IVdata e.g: Vred output of "GridCorrNorm.m"
% Biases: Vector(a scalar if it is 1D), the biases that you want to use e.g: [0.1], [0.1, 0.198].Remark: with bias range(-0.2V,0.2V), don't use 0.2V 
% Plotname: Vector of strings(same dimension as Biases), the plot names of the output plots: ["name one"] or ["name one","name two"], etc.

function [] = gridPlotSlices(IVdata,V,Biases,plotname)

% load colourmap
color_scale_resolution = 1000; % 1000 evenly spaced colour points
cm_viridis = viridis(color_scale_resolution); % Default matplotlib(for LAIR)
cm_inferno = inferno(color_scale_resolution);
cm_magma = magma(color_scale_resolution);
cm_plasma = plasma(color_scale_resolution);

% Homework
% IVdata is to process the data, will be different for Createc
IVdata = flip(permute(IVdata,[1 3 2]),2);

% NegRamp is to determine if V is inverted, True if inverted.
NegRamp = V(length(V))-V(1) < 0;

% Homework: To add position to plot to manually adjust the size.
% Plot the biases selected, if there is no such bias exist in the function V, then choose the one which is closest(round-up)
for i = 1:length(plotname)
    figure('Name', plotname(i))
        if NegRamp
             temp_ind = find(V < Biases(i),1);
        else
             temp_ind = find(V > Biases(i),1);
        end
    clims = [0,3E-9];   
    imagesc(squeeze(IVdata(temp_ind,:,:)),clims)
    colorbar
    colormap(cm_magma)
        axis image
        title([num2str(V(temp_ind)),' V'])

end
