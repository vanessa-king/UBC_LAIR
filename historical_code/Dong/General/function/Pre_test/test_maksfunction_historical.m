dataCube = rand(10 , 25);
point1 = [1,4];
point2 = [size(dataCube,1),20];

%[mask,comment] = createLineSegmentMask(size(dataCube), point1, point2);

% Initialize mask with zeros
mask = zeros(size(dataCube));
%line interpolation
X = [point1(1),point2(1)];
Y = [point1(2),point2(2)];
%prelim assignment of x and y coords
x = min(X):max(X);
y = min(Y):max(Y);
if length(y)> length(x)
    %stretch x and round to integer
    x = round(linspace(min(X),max(X),length(y)));
else 
    %stretch y and round to integer
    y = round(linspace(min(Y),max(Y),length(x)));
end

for n = 1:length(x)
    mask(x(n),y(n)) = 1;
end

