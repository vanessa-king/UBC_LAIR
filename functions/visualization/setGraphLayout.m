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
        ax.XTick = [-0.04 -0.02 0 0.02 0.04];        
    case "dIdV"
        ax.FontSize = 20;
        ax.XLabel.String = 'bias(V)';
        ax.YLabel.String = 'dI/dV[a.u.]';
        ax.XTick = [-0.04 -0.02 0 0.02 0.04];        
    case "IV_fwdbwd"
        ax.FontSize = 20;
        ax.XLabel.String = 'bias(V)';
        ax.YLabel.String = 'I(V)[A]';
        legend('bwd', 'fwd','location','southeast')       
    case "dIdV_fwdbwd"
        ax.FontSize = 20;
        ax.XLabel.String = 'bias(V)';
        ax.YLabel.String = 'dI/dV[a.u.]';
        legend('bwd', 'fwd','location','southeast')
end