function stepdidv(norm_didv2, step,Med,sg)

 figure(1)
    imagesc(rot90(norm_didv2(:,:,1))) %plot 2D image
    
    const=50;
    
    hold on
    pbaspect([1 1 1]) %image size ratio [x,y,1]
    set(gcf, 'Colormap', gray)
   caxis([Med(1)-const*sg(1) Med(1)+const*sg(1)])
   
   pos1 = round(ginput(1));
   pos2 = round(ginput(1));
   
     slope_x=abs(pos1(1)-pos2(1));
    slope_y=abs(pos1(2)-pos2(2));
    ratio = (slope_y)/(slope_x);
    
x=[];
y=[];
lstep=(pos2-pos1)/(step-1);
% for x 
if pos1(1) < pos2(1)
     temp=pos1(1):lstep(1):pos2(1);
    for i=1:step
       x(i)=pos1(1)+(temp(i)-pos1(1))/ratio;
    end
elseif pos1(1) > pos2(1)
     temp=pos2(1):lstep(1):pos1(1);
    for i=1:step
        x(i)=pos2(1)+(temp(i)-pos2(1))/ratio;
    end   
    x=fliplr(x);
end
% for y
if pos1(2) < pos2(2)
     temp=pos1(2):lstep(2):pos2(2);
    for i=1:step
%        y(i)=pos1(2)+(temp(i)-pos1(2))*ratio;
 y(i)=pos1(2)+(temp(i)-pos1(2));
    end
elseif pos1(2) > pos2(2)
     temp=pos2(2):lstep(2):pos1(2);
    for i=1:step
%         y(i)=pos2(2)+(temp(i)-pos2(2))*ratio;
  y(i)=pos2(2)+(temp(i)-pos2(2));
    end   
    y=fliplr(y);
end

%{
if pos1(2) < pos2(2)
    for i=pos1(2):lstep(2):pos1(1)+round(slope_y*ratio)
        y(i-pos1(1)+1)=pos1(1)+(i-pos1(1))/ratio;
    end
elseif pos1(1) > pos2(1)
    for i=pos2(1):lstep(1):pos2(1)+round(slope_y*ratio)
        y(i-pos2(1)+1)=pos2(1)+(i-pos2(1))/ratio;
    end   
    y=fliplr(y);
end
%}
%{
if pos1(2) < pos2(2)
    for j=pos1(2):pos2(2)
        y(j-pos1(2)+1)=j;
    end
elseif pos1(2) > pos2(2)
    for j=pos2(2):pos1(2)
        y(j-pos2(2)+1)=j;
    end   
    y=fliplr(y);
end
%}
position=zeros(2,length(x));
position(1,:)=round(x(:)); % solve the ingeter one!
position(2,:)=y(:);

%
figure (2)
for i=1:size(position,2)
    plot(label,reshape(norm_didv2(position(1,i),position(2,i),:),200,1)) % you can choose j value from 1:200
    hold on
end