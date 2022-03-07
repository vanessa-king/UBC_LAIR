%
% DESCRIPTION
% This function takes the average of the I(V) data and plots it. (For Tesla, this is called in the Plot 1D Density section.)
%
% PARAMETERS
%
%   I size: number_bias_layer x grid size x grid size
%   V size: number_bias_layer x 1
%

function [avg_iv_data] = gridAvg(I, V)

%
% size(V) returns a row vector whose elements are the lengths of the corresponding dimensions of V
% avg_iv_data is the mean of I based on the dimensions specified in the vector [a b] - here, [3 2] is the total grid size and the order of those numbers probably does not matter.
%

[number_bias_layer, ~] = size(V);
avg_iv_data = mean(I, [3 2]);

%
% A figure of the average iv data is made.
%

figure();
plot(V,reshape(avg_iv_data(:),number_bias_layer,1))
xlabel("V")
ylabel("average iv data")
end

