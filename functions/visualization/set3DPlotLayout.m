function [ax] = set3DPlotLayout(LayoutCase)
%This function sets the format of 3D data.  
% You can add your own layout as a case here. When you add your own format, 
% try to choose the identifier (i.e.LayoutCase) to be unique and informative. e.g. "3D_waterfall_plot".
% The output of this function is ax, which includes all axes properties. 

% M. Altthaler, March 2024

arguments
    LayoutCase  {mustBeText} %string
end

ax = gca;
switch LayoutCase
    case "3D_waterfall_dIdV"
        ax.XLabel.String = '# of spectra';
        ax.YLabel.String = 'bias voltage (V)';
        ax.ZLabel.String = 'dIdV (arb. u.)';
        view(315, 45);
    case "3D_waterfall_IV"
        ax.XLabel.String = '# of spectra';
        ax.YLabel.String = 'bias voltage (V)';
        ax.ZLabel.String = 'I(V)[A]';
        view(315, 45);

end