% plot averaged dIdV from different regions of grid 1

%% GB_BL

figure;
errorbar(data.grid4.V_reduced, data.grid4.GB_BL1_dIdV, data.grid4.GB_BL1_dIdV_STD, 'Color','red')
hold on
errorbar(data.grid4.V_reduced, data.grid4.GB_BL2_dIdV, data.grid4.GB_BL2_dIdV_STD, 'Color','red')
errorbar(data.grid4.V_reduced, data.grid4.GB_BL3_dIdV, data.grid4.GB_BL3_dIdV_STD, 'Color','red')
hold off

%% top_BL

figure;
errorbar(data.grid4.V_reduced, data.grid4.top_BL1_dIdV, data.grid4.top_BL1_dIdV_STD, 'Color','green')
hold on
errorbar(data.grid4.V_reduced, data.grid4.top_BL2_dIdV, data.grid4.top_BL2_dIdV_STD, 'Color','green')
errorbar(data.grid4.V_reduced, data.grid4.top_BL3_dIdV, data.grid4.top_BL3_dIdV_STD, 'Color','green')
hold off

%% bottom_BL

figure;
errorbar(data.grid4.V_reduced, data.grid4.bottom_BL1_dIdV, data.grid4.bottom_BL1_dIdV_STD, 'Color','blue')
hold on
errorbar(data.grid4.V_reduced, data.grid4.bottom_BL2_dIdV, data.grid4.bottom_BL2_dIdV_STD, 'Color','blue')
errorbar(data.grid4.V_reduced, data.grid4.bottom_BL3_dIdV, data.grid4.bottom_BL3_dIdV_STD, 'Color','blue')
hold off

%% average and plot together

data.grid4.GB_BL_dIdV_avg = mean([data.grid4.GB_BL1_dIdV, data.grid4.GB_BL2_dIdV, data.grid4.GB_BL3_dIdV], 2);
[data.grid4.GB_BL_dIdV_avg_norm, data.grid4.GB_BL_dIdV_avg_normfactor] = normRG(data.grid4.GB_BL_dIdV_avg, -1e-13);
data.grid4.top_BL_dIdV_avg = mean([data.grid4.top_BL1_dIdV, data.grid4.top_BL2_dIdV, data.grid4.top_BL3_dIdV], 2);
[data.grid4.top_BL_dIdV_avg_norm, data.grid4.top_BL_dIdV_avg_normfactor] = normRG(data.grid4.top_BL_dIdV_avg, -1e-13);
data.grid4.bottom_BL_dIdV_avg = mean([data.grid4.bottom_BL1_dIdV, data.grid4.bottom_BL2_dIdV, data.grid4.bottom_BL3_dIdV], 2);
[data.grid4.bottom_BL_dIdV_avg_norm, data.grid4.bottom_BL_dIdV_avg_normfactor] = normRG(data.grid4.bottom_BL_dIdV_avg, -1e-13);

data.grid4.GB_BL_dIdV_avg_std  = sqrt((data.grid4.GB_BL1_dIdV_STD.^2 + data.grid4.GB_BL2_dIdV_STD.^2 + data.grid4.GB_BL3_dIdV_STD.^2) / 9);
data.grid4.top_BL_dIdV_avg_std  = sqrt((data.grid4.top_BL1_dIdV_STD.^2 + data.grid4.top_BL2_dIdV_STD.^2 + data.grid4.top_BL3_dIdV_STD.^2) / 9);
data.grid4.bottom_BL_dIdV_avg_std  = sqrt((data.grid4.bottom_BL1_dIdV_STD.^2 + data.grid4.bottom_BL2_dIdV_STD.^2 + data.grid4.bottom_BL3_dIdV_STD.^2) / 9);

figure; hold on;
x = data.grid4.V_reduced;
y = data.grid4.GB_BL_dIdV_avg_norm;
yerr = data.grid4.GB_BL_dIdV_avg_std*data.grid4.GB_BL_dIdV_avg_normfactor;
% Compute upper and lower bounds
y_upper = y + yerr;
y_lower = y - yerr;

% Create filled area between lower and upper bounds
x_fill = [x; flipud(x)];
y_fill = [y_upper; flipud(y_lower)];

% Transparent shaded error band
fill(x_fill, y_fill, 'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
GB_BL =plot(data.grid4.V_reduced, data.grid4.GB_BL_dIdV_avg_norm,'color', 'red');

x = data.grid4.V_reduced;
y = data.grid4.top_BL_dIdV_avg_norm;
yerr = data.grid4.top_BL_dIdV_avg_std* data.grid4.top_BL_dIdV_avg_normfactor;
% Compute upper and lower bounds
y_upper = y + yerr;
y_lower = y - yerr;

% Create filled area between lower and upper bounds
x_fill = [x; flipud(x)];
y_fill = [y_upper; flipud(y_lower)];

% Transparent shaded error band
fill(x_fill, y_fill, 'green', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
top_BL=plot(data.grid4.V_reduced, data.grid4.top_BL_dIdV_avg_norm,'color', 'green');

x = data.grid4.V_reduced;
y = data.grid4.bottom_BL_dIdV_avg_norm;
yerr = data.grid4.bottom_BL_dIdV_avg_std*data.grid4.bottom_TL_dIdV_avg_normfactor;
% Compute upper and lower bounds
y_upper = y + yerr;
y_lower = y - yerr;

% Create filled area between lower and upper bounds
x_fill = [x; flipud(x)];
y_fill = [y_upper; flipud(y_lower)];

% Transparent shaded error band
fill(x_fill, y_fill, 'blue', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
bottom_BL=plot(data.grid4.V_reduced, data.grid4.bottom_BL_dIdV_avg_norm,'color', 'blue');
xline(-2.1)
xline(1.0)
yline(0.1)
%legend([GB_BL, top_BL, bottom_BL], {'GB BL', 'top BL', 'bottom BL'});
xlabel('V_B [V]')
ylabel('dIdV')

%% TL
%% GB_TL

figure;
errorbar(data.grid4.V_reduced, data.grid4.GB_TL1_dIdV, data.grid4.GB_TL1_dIdV_STD, 'Color','red')
hold on
errorbar(data.grid4.V_reduced, data.grid4.GB_TL2_dIdV, data.grid4.GB_TL2_dIdV_STD, 'Color','red')
errorbar(data.grid4.V_reduced, data.grid4.GB_TL3_dIdV, data.grid4.GB_TL3_dIdV_STD, 'Color','red')
hold off

%% top_TL

figure;
errorbar(data.grid4.V_reduced, data.grid4.top_TL1_dIdV, data.grid4.top_TL1_dIdV_STD, 'Color','green')
hold on
errorbar(data.grid4.V_reduced, data.grid4.top_TL2_dIdV, data.grid4.top_TL2_dIdV_STD, 'Color','green')
errorbar(data.grid4.V_reduced, data.grid4.top_TL3_dIdV, data.grid4.top_TL3_dIdV_STD, 'Color','green')
hold off

%% bottom_TL

figure;
errorbar(data.grid4.V_reduced, data.grid4.bottom_TL1_dIdV, data.grid4.bottom_TL1_dIdV_STD, 'Color','blue')
hold on
errorbar(data.grid4.V_reduced, data.grid4.bottom_TL2_dIdV, data.grid4.bottom_TL2_dIdV_STD, 'Color','blue')
errorbar(data.grid4.V_reduced, data.grid4.bottom_TL3_dIdV, data.grid4.bottom_TL3_dIdV_STD, 'Color','blue')
hold off

%% average and plot together

data.grid4.GB_TL_dIdV_avg = mean([data.grid4.GB_TL1_dIdV, data.grid4.GB_TL2_dIdV, data.grid4.GB_TL3_dIdV], 2);
[data.grid4.GB_TL_dIdV_avg_norm, data.grid4.GB_TL_dIdV_avg_normfactor] = normRG(data.grid4.GB_TL_dIdV_avg, -1e-13);
data.grid4.top_TL_dIdV_avg = mean([data.grid4.top_TL1_dIdV, data.grid4.top_TL2_dIdV, data.grid4.top_TL3_dIdV], 2);
[data.grid4.top_TL_dIdV_avg_norm, data.grid4.top_TL_dIdV_avg_normfactor] = normRG(data.grid4.top_TL_dIdV_avg, -1e-13);
data.grid4.bottom_TL_dIdV_avg = mean([data.grid4.bottom_TL1_dIdV, data.grid4.bottom_TL2_dIdV, data.grid4.bottom_TL3_dIdV], 2);
[data.grid4.bottom_TL_dIdV_avg_norm, data.grid4.bottom_TL_dIdV_avg_normfactor] = normRG(data.grid4.bottom_TL_dIdV_avg, -1e-13);

data.grid4.GB_TL_dIdV_avg_std  = sqrt((data.grid4.GB_TL1_dIdV_STD.^2 + data.grid4.GB_TL2_dIdV_STD.^2 + data.grid4.GB_TL3_dIdV_STD.^2) / 9);
data.grid4.top_TL_dIdV_avg_std  = sqrt((data.grid4.top_TL1_dIdV_STD.^2 + data.grid4.top_TL2_dIdV_STD.^2 + data.grid4.top_TL3_dIdV_STD.^2) / 9);
data.grid4.bottom_TL_dIdV_avg_std  = sqrt((data.grid4.bottom_TL1_dIdV_STD.^2 + data.grid4.bottom_TL2_dIdV_STD.^2 + data.grid4.bottom_TL3_dIdV_STD.^2) / 9);

figure; hold on;
x = data.grid4.V_reduced;
y = data.grid4.GB_TL_dIdV_avg_norm;
yerr = data.grid4.GB_TL_dIdV_avg_std*data.grid4.GB_TL_dIdV_avg_normfactor;
% Compute upper and lower bounds
y_upper = y + yerr;
y_lower = y - yerr;

% Create filled area between lower and upper bounds
x_fill = [x; flipud(x)];
y_fill = [y_upper; flipud(y_lower)];

% Transparent shaded error band
fill(x_fill, y_fill, 'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
GB_TL =plot(data.grid4.V_reduced, data.grid4.GB_TL_dIdV_avg_norm,'color', 'red');

x = data.grid4.V_reduced;
y = data.grid4.top_TL_dIdV_avg_norm;
yerr = data.grid4.top_TL_dIdV_avg_std*data.grid4.top_TL_dIdV_avg_normfactor;
% Compute upper and lower bounds
y_upper = y + yerr;
y_lower = y - yerr;

% Create filled area between lower and upper bounds
x_fill = [x; flipud(x)];
y_fill = [y_upper; flipud(y_lower)];

% Transparent shaded error band
fill(x_fill, y_fill, 'green', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
top_TL=plot(data.grid4.V_reduced, data.grid4.top_TL_dIdV_avg_norm,'color', 'green');

x = data.grid4.V_reduced;
y = data.grid4.bottom_TL_dIdV_avg_norm;
yerr = data.grid4.bottom_TL_dIdV_avg_std*data.grid4.bottom_TL_dIdV_avg_normfactor;
% Compute upper and lower bounds
y_upper = y + yerr;
y_lower = y - yerr;

% Create filled area between lower and upper bounds
x_fill = [x; flipud(x)];
y_fill = [y_upper; flipud(y_lower)];

% Transparent shaded error band
fill(x_fill, y_fill, 'blue', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
bottom_TL=plot(data.grid4.V_reduced, data.grid4.bottom_TL_dIdV_avg_norm,'color', 'blue');
xline(-2.3)
xline(1.2)
yline(0.1)
legend([GB_TL, top_TL, bottom_TL], {'GB TL', 'top TL', 'bottom TL'});
xlabel('V_B [V]')
ylabel('dIdV')