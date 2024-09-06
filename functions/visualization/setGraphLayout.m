function [ax] = setGraphLayout(LayoutCase)
%This function sets a graph format. 
% You can add your own layout as a case here. When you add your own format, 
% try to choose the identifier (i.e.LayoutCase) to be unique and informative. e.g. "CaPt_dIdV" or "CaPt_Jisun_IV".
% The output of this function is ax, which includes all axes properties. 

arguments
    LayoutCase  {mustBeText} %string
end

ax = gca;
switch LayoutCase
    case "IV"
        ax.FontSize = 20;
        ax.XLabel.String = 'bias(V)';
        ax.YLabel.String = 'I(V)[A]';          
    case "dIdV"
        ax.FontSize = 20;
        ax.XLabel.String = 'bias(V)';
        ax.YLabel.String = 'dI/dV[a.u.]';        
    case "IV_fwdbwd"
        ax.FontSize = 20;
        ax.XLabel.String = 'bias(V)';
        ax.YLabel.String = 'I(V)[A]';
        legend('fwd', 'bwd','location','southeast')       
    case "dIdV_fwdbwd"
        ax.FontSize = 20;
        ax.XLabel.String = 'bias(V)';
        ax.YLabel.String = 'dI/dV[a.u.]';
        legend('fwd', 'bwd','location','southeast')
    case "transparent_IV"
        ax.FontSize = 12;
        ax.Title.String = 'I/V Profiles with average';
        ax.XLabel.String = 'Bias Voltage [V]';
        ax.YLabel.String = 'I/V [a.u.]';
        axis square;
    case "transparent_dIdV"
        ax.FontSize = 12;
        ax.Title.String = 'dI/dV Profiles with average';
        ax.XLabel.String = 'Bias Voltage [V]';
        ax.YLabel.String = 'dI/dV [a.u.]';
        axis square;
    case "meanSTDshadedPlot"
        ax.FontSize = 12;
        ax.Title.String = 'mean and STD plot';
        ax.XLabel.String = 'Bias Voltage [V]';
        ax.YLabel.String = 'dI/dV [a.u.]';
        axis square;

end