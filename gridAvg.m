function [avg_iv_data] = gridAvg(iv_data, V)
%GRIDAVG Takes the average of iv_data.
%   iv_data size: num_layer x grid size x grid size
%   V size: num_layer x 1
%% iv_data Average
[elayer, ~] = size(V);
avg_iv_data = mean(iv_data, [3 2]);

figure();
plot(V,reshape(avg_iv_data(:),elayer,1))
xlabel("V")
ylabel("Avg iv data")
end

