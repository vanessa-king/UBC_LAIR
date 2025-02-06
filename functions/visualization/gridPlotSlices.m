function [plot_names,Biases,comment] = gridPlotSlices(I, V, Biases, plotname)
% GRIDPLOTSLICES Takes a slice of dI/dV at certain biases and saves them as separate plots.
%   I = 3D array (x*y*energy), raw I(V) data, e.g., grid.I
%   V = Vector, the measured biases of the I(V), e.g., Vred output of gridCorrNorm
%   Biases = Vector (or scalar if it is 1D), the biases that you want to use, e.g., [0.1], [0.1, 0.198]. Remark: with bias range (-0.2V, 0.2V), don't use 0.2V 
%   plotname = Vector of strings (same dimension as Biases), the plot names of the output plots, e.g., ["name one"] or ["name one", "name two"], etc.


% No default values needed here.
arguments
   I
   V
   Biases
   plotname
end

comment = sprintf("gridPlotSlices(bias=%.5f)|", Biases);

    % load colourmap
    color_scale_resolution = 1000; % 1000 evenly spaced colour points
    cm_magma = magma(color_scale_resolution);

    N = length(Biases);

    % NegRamp is to determine if V is inverted, True if inverted.
    NegRamp = V(length(V)) - V(1) < 0;

    plot_names = {};
    
    % Plot the biases selected, if there is no such bias exist in the function V, then choose the one which is closest (round-up)
    for k = 1:N
        if NegRamp
            temp_ind = find(V < Biases(k), 1);
        else
            temp_ind = find(V > Biases(k), 1);
        end
        
        % Create a new figure for each plot
        figure('Name', [plotname{1}, 'Biases', num2str(Biases(k))]);
        %creat a new plot name for each figure
        plot_names{k} = [plotname{1}, 'Biases', num2str(Biases(k))];
        clims = [0, 3E-11];   
        imagesc(squeeze(permute(I(:, :, temp_ind),[2, 1, 3])), clims); %permute to xyV  for plotting
        colorbar;
        colormap(cm_magma);
        axis image;
        title([num2str(V(temp_ind)), ' V']);
    end
end
