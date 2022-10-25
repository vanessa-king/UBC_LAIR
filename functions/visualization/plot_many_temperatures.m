%%
% This code takes Matrix data that have already been processed into Matlab
% workspaces (through the first 4 sections of CaPt_analysis code) and plots the averaged dI/dVs.
%

% This part of the code loads the files to be plotted, and defines the
% color of each line (r for red, g for green, b for blue, c for cyan, m for
% magenta, y for yellow, k for black).
%

load('C:\Users\jamesday\Documents\UBC\Data\CaPt\Tesla-Code\output\Ca_210715_04K_0T_61Z.mat')
plot(V_reduced, avg_didv,'b')
title('Ca-covered FeAs surface')
xlabel('V')
ylabel('dI/dV [a.u.]')
hold on
load('C:\Users\jamesday\Documents\UBC\Data\CaPt\Tesla-Code\output\Ca_210715_06K_0T_69Z.mat')
plot(V_reduced, avg_didv,'c')
load('C:\Users\jamesday\Documents\UBC\Data\CaPt\Tesla-Code\output\Ca_210715_10K_0T_79Z.mat')
plot(V_reduced, avg_didv,'r')

%
% This part of the code sets the plot limits and legend. It would be
% nice if the legend were set automatically from the filepath.
%

xlim([-0.04 0.04])
ylim([0 4e-9])
xticks([-0.04 -0.02 0 0.02 0.04])
yticks([0 1e-9 2e-9 3e-9 4e-9])
set(gca,'FontSize',16)
leg = legend('4K', '6K', '10K');
leg.Location = 'southeast';
