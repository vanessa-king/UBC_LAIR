%
% DESCRIPTION
% This function takes the average of the iv_data and plots it. This is called in the Plot 1D Density section.
%
% PARAMETERS
%   num_layer: comes from SOMEWHERE
%
%   iv_data size: num_layer x grid size x grid size
%   V size: num_layer x 1
%

function [avg_iv_data] = gridAvg(iv_data, V)

%
% size(V) returns a row vector whose elements are the lengths of the corresponding dimensions of V
% avg_iv_data is the mean of iv_data based on the dimensions specified in the vector [a b]
%

[elayer, ~] = size(V);
avg_iv_data = mean(iv_data, [3 2]);

%
% A figure of the average iv data is made.
%

figure();
plot(V,reshape(avg_iv_data(:),elayer,1))
xlabel("V")
ylabel("average iv data")
end

