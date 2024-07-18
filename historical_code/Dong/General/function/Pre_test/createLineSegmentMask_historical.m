function [mask,comment] = createLineSegmentMask(imageSize, point1, point2)
%create a mask representing a line segment between two points
%   Returns a mask of imageSize which represents a line segment from point1 
%   to point2 using Bresenham's line algorythm. The function does not
%   accept point coordinates outside the limits of the image size.

%arguments:
%   imageSize   Size of the image [x_max, y_max]
%   point1      start point [x, y]
%   point2      end pont [x, y]

%returns: 
%   mask        logical mask representing the line between point1 and point2
%   comment     LOG comment

% Nov. 2023 M. Altthaler

arguments
    imageSize   {mustBeNumeric,mustBePositive}
    point1      {mustBeNumeric,mustBePositive}
    point2      {mustBeNumeric,mustBePositive}
end


% LOG comment:
comment=sprintf('createLineMask(imagesize = [%d,%d], point1 = [%d,%d],point2 = [%d,%d])',imageSize(1),imageSize(2),point1(1),point1(2),point2(1),point2(2));

% check if the point coordinates are within the image size:
if point1(1)>imageSize(1)||point1(2)>imageSize(2)||point2(1)>imageSize(1)||point2(2)>imageSize(2)
    disp('Coordinates of point(s) exceed image size.')
    mask=[];
    return
end


% Initialize mask with zeros
mask = zeros(imageSize);
%line interpolation
X = [point1(1),point2(1)];
Y = [point1(2),point2(2)];
%assignment of x and y coords
x = min(X):max(X);
y = min(Y):max(Y);
if length(y)> length(x)
    %stretch x and round to integer
    x = round(linspace(min(X),max(X),length(y)));
else 
    %stretch y and round to integer
    y = round(linspace(min(Y),max(Y),length(x)));
end
%set mask to 1 for all (x,y) coordinates
for n = 1:length(x)
    mask(x(n),y(n)) = 1;
end

end