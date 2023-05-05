%
% DESCRIPTION
% This function takes the average of the I(V) data and plots it. (For Tesla, this is called in the Plot 1D Density section.)
%
% PARAMETERS
%
%   I size: number_bias_layer x grid size x grid size
%   V size: number_bias_layer x 1
%

function [avg_I, comment] = gridAvg(I, V, plotBool)

%setting default value for plotBool; further specifications for arguments
%could be made here, e.g.: I {mustBe...}
arguments
    I 
    V
    plotBool = 0
end

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Never plot data (e.g. the whole gird) in the comment, only plot the values
%('=<VARn_value>') of variables that decide/affect how the function
%processes data (e.g. order of fit, ...) 
%Note convert all <VARn_value> to strings;
comment = sprintf("gridAvg(I, V, plotBool=%s)|", mat2str(plotBool));



%
% size(V) returns a row vector whose elements are the lengths of the corresponding dimensions of V
% avg_I is the mean of I based on the dimensions specified in the vector [a b] - here, [3 2] is the total grid size and the order of those numbers probably does not matter.
%

[number_bias_layer, ~] = size(V);
avg_I = mean(I, [3 2]);

%
% A figure of the average iv data is made.
%
if plotBool == 1
  figure();
  plot(V,reshape(avg_I(:),number_bias_layer,1))
  xlabel("V")
  ylabel("average I(V) data")
end
end

