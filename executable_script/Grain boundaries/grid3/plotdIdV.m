% plot averaged dIdV from different regions of grid 1

%% GB

figure;
errorbar(data.grid3.V_reduced, data.grid3.GB1_dIdV, data.grid3.GB1_dIdV_STD, 'Color','red')
hold on
errorbar(data.grid3.V_reduced, data.grid3.GB2_dIdV, data.grid3.GB2_dIdV_STD, 'Color','red')
errorbar(data.grid3.V_reduced, data.grid3.GB3_dIdV, data.grid3.GB3_dIdV_STD, 'Color','red')
hold off

%% top

figure;
errorbar(data.grid3.V_reduced, data.grid3.top1_dIdV, data.grid3.top1_dIdV_STD, 'Color','green')
hold on
errorbar(data.grid3.V_reduced, data.grid3.top2_dIdV, data.grid3.top2_dIdV_STD, 'Color','green')
errorbar(data.grid3.V_reduced, data.grid3.top3_dIdV, data.grid3.top3_dIdV_STD, 'Color','green')
hold off

%% bottom

figure;
errorbar(data.grid3.V_reduced, data.grid3.bottom1_dIdV, data.grid3.bottom1_dIdV_STD, 'Color','blue')
hold on
errorbar(data.grid3.V_reduced, data.grid3.bottom2_dIdV, data.grid3.bottom2_dIdV_STD, 'Color','blue')
errorbar(data.grid3.V_reduced, data.grid3.bottom3_dIdV, data.grid3.bottom3_dIdV_STD, 'Color','blue')
hold off

%% average and plot together

data.grid3.GB_dIdV_avg = mean([data.grid3.GB1_dIdV, data.grid3.GB2_dIdV, data.grid3.GB3_dIdV], 2);
[data.grid3.GB_dIdV_avg_norm, data.grid3.GB_dIdV_avg_normfactor] = normRG(data.grid3.GB_dIdV_avg, -1.3e-13);
data.grid3.top_dIdV_avg = mean([data.grid3.top1_dIdV, data.grid3.top2_dIdV, data.grid3.top3_dIdV], 2);
[data.grid3.top_dIdV_avg_norm, data.grid3.top_dIdV_avg_normfactor] = normRG(data.grid3.top_dIdV_avg, -1.3e-13);
data.grid3.bottom_dIdV_avg = mean([data.grid3.bottom1_dIdV, data.grid3.bottom2_dIdV, data.grid3.bottom3_dIdV], 2);
[data.grid3.bottom_dIdV_avg_norm, data.grid3.bottom_dIdV_avg_normfactor] = normRG(data.grid3.bottom_dIdV_avg, -1.3e-13);

data.grid3.GB_dIdV_avg_std  = sqrt((data.grid3.GB1_dIdV_STD.^2 + data.grid3.GB2_dIdV_STD.^2 + data.grid3.GB3_dIdV_STD.^2) / 9);
data.grid3.top_dIdV_avg_std  = sqrt((data.grid3.top1_dIdV_STD.^2 + data.grid3.top2_dIdV_STD.^2 + data.grid3.top3_dIdV_STD.^2) / 9);
data.grid3.bottom_dIdV_avg_std  = sqrt((data.grid3.bottom1_dIdV_STD.^2 + data.grid3.bottom2_dIdV_STD.^2 + data.grid3.bottom3_dIdV_STD.^2) / 9);

figure; hold on;
x = data.grid3.V_reduced;
y = data.grid3.GB_dIdV_avg_norm;
yerr = data.grid3.GB_dIdV_avg_std*data.grid3.GB_dIdV_avg_normfactor;
% Compute upper and lower bounds
y_upper = y + yerr;
y_lower = y - yerr;

% Create filled area between lower and upper bounds
x_fill = [x; flipud(x)];
y_fill = [y_upper; flipud(y_lower)];

% Transparent shaded error band
fill(x_fill, y_fill, 'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
GB =plot(data.grid3.V_reduced, data.grid3.GB_dIdV_avg_norm,'color', 'red');

x = data.grid3.V_reduced;
y = data.grid3.top_dIdV_avg_norm;
yerr = data.grid3.top_dIdV_avg_std*data.grid3.top_dIdV_avg_normfactor;
% Compute upper and lower bounds
y_upper = y + yerr;
y_lower = y - yerr;

% Create filled area between lower and upper bounds
x_fill = [x; flipud(x)];
y_fill = [y_upper; flipud(y_lower)];

% Transparent shaded error band
fill(x_fill, y_fill, 'green', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
top=plot(data.grid3.V_reduced, data.grid3.top_dIdV_avg_norm,'color', 'green');

x = data.grid3.V_reduced;
y = data.grid3.bottom_dIdV_avg_norm;
yerr = data.grid3.bottom_dIdV_avg_std*data.grid3.bottom_dIdV_avg_normfactor;
% Compute upper and lower bounds
y_upper = y + yerr;
y_lower = y - yerr;

% Create filled area between lower and upper bounds
x_fill = [x; flipud(x)];
y_fill = [y_upper; flipud(y_lower)];

% Transparent shaded error band
fill(x_fill, y_fill, 'blue', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
bottom=plot(data.grid3.V_reduced, data.grid3.bottom_dIdV_avg_norm,'color', 'blue');
xline(-2.1)
xline(1.05)
yline(0.1)
legend([GB, top, bottom], {'GB', 'Top', 'Bottom'});
xlabel('V_B [V]')
ylabel('dIdV')