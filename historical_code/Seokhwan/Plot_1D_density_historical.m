%% 1D Density Plot + Average dI/dV
%% Parameters
transp =0.0075;
lwidth1=1.5;
lwidth2=2.5;
pcolorb=[0 0 0];
%% Plot
figure()
for i=1:20
for j=1:20
    plot1 =plot(label,reshape(dIdV(i,j,:),elayer,1),'color',pcolorb,'LineWidth',lwidth1);
    plot1.Color(4)=transp;
    hold on
end
end
plot(label,reshape(avg_dIdV(:),elayer,1),'color',pcolorb,'LineWidth',lwidth2)

title('Average dI/dV','fontsize',28)
xlabel('Bias Voltage [V]','fontsize',24)
ylabel('dI/dV [a.u.]','fontsize',24)
set(gca,'fontsize',24)
hold off
axis square