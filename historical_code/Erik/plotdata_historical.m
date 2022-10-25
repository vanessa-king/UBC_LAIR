data = Load_Line_Spectra_Erik

i = data.iv;
v = data.V;
% [m,ind] = min(abs(v));
% i(ind) = []; % remove 0 to prevent problems
% v(ind) = [];

i2 = movmean(i,1);
didv = diff(i2)./diff(v);
iv2 = sqrt((i2(1:end-1,:)./v(1:end-1)).^2+1e-17);
didv_norm = didv./iv2;
v2 = v(1:end-1);
%v2(117) = [];
%didv_norm(117) = [];

figure(1)
plot(v,i*1e9,'linewidth',2)
xlim([-1 1])
xlabel('Bias (V)','fontsize',14)
ylabel('I (nA)','fontsize',14)
set(gca,'fontsize',14)

figure(2)
plot(v(1:end-1),didv*1e9,'linewidth',2)
xlim([-1 1])
xlabel('Bias (V)')
ylabel('dI/dV (nS)')

figure(3)
plot(v2,didv_norm,'linewidth',2)
xlim([-0.3 0.2])
xlabel('Bias (V)','fontsize',14)
ylabel('(dI/dV) / (I/V)','fontsize',14)
set(gca,'fontsize',14)

%%

GRD = Load_IV_Grid_Erik;

i = GRD.iv;
v = GRD.V;
x = GRD.x;
y = GRD.y;

i2 = movmean(i,5);
didv = diff(i2)./diff(v);
iv2 = sqrt((i2(1:end-1,:,:)./v(1:end-1)).^2+1e-17);
didv_norm = didv./iv2;
v2 = v(1:end-1);

%%

figure(1)
imagesc(x,y,squeeze(didv_norm(300,:,:)))

figure(2);
plot(v2,didv_norm(:,40,40))

%%

figure(3)
for i = 1:20
    for j = 1:20
        h = plot(v2,didv_norm(:,i,j),'r');
        h.Color(4) = 0.1;
        hold on
    end
end
hold off
ylim([-0.05 0.1])
xlabel('Bias (V)','fontsize',14)
ylabel('(dI/dV) / (I/V)','fontsize',14)
set(gca,'fontsize',14)

figure(4)
for i = 70:80
    for j = 1:10
        h = plot(v2,didv_norm(:,i,j),'b');
        h.Color(4) = 0.1;
        hold on
    end
end
hold off
ylim([-0.05 0.1])
xlabel('Bias (V)','fontsize',14)
ylabel('(dI/dV) / (I/V)','fontsize',14)
set(gca,'fontsize',14)