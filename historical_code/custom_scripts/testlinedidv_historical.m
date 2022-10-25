function testlinedidv(norm_didv2, point)

% ----------Plot line dIdV----------
for k=1:200
    label(k) = -404+4*k; % label out the scale of k
end

for j=1:200
for k=1:200
    avg_didv_x(j,k)= mean(mean(norm_didv2(:,j,k)));
end
end

%----plot a vertical line didv----
%pick points along y direction
figure ()
for j=1:point
%     plot(label,reshape(avg_didv_x(j,:),1,200)) % you can choose j value from 1:200
    plot(label,reshape(norm_didv2(1,j,:),1,200)) % you can choose j value from 1:200
    hold on
end

%----plot a horizontal line didv----
%pick points along x direction
figure ()
for i=1:point
    plot(label,reshape(norm_didv2(i,1,:),1,200)) %fixedj=1, i value from 1:200
    hold on
end
