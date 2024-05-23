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




%line interpolation
%x(P1) -> x(P2)
if point1(1)>point2(1)
    x = point1(1):-1:point2(1);
else
    x = point1(1):point2(1);  
end 
%y(P1) -> y(P2)
if point1(2)>point2(2)
    y = point1(2):-1:point2(2);
else
    y = point1(2):point2(2);
end

%adjust x and y to match in length
if length(y)> length(x)
    %stretch x and round to integer
    x = round(linspace(x(1),x(end),length(y)));
elseif length(x)> length(y)
    %stretch y and round to integer
    y = round(linspace(y(1),y(end),length(x)));
end

% Initialize mask with zeros
mask = zeros(imageSize);
%set mask to 1 for all (x,y) coordinates
for n = 1:length(x)
    mask(x(n),y(n)) = 1;
end

end