function [mask,comment] = createLineMask(imageSize, point1, point2)
%create a mask representing a line between two points
%   Returns a mask of imageSize which represents a line from point1 to
%   point2 using Bresenham's line algorythm

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

% check if the point coordinates fit inside the image:
if point1(1)>imageSize(1)||point1(2)>imageSize(2)||point2(1)>imageSize(1)||point2(2)>imageSize(2)
    disp('Coordinates of point(s) exceed image size.')
    mask=[];
    return
end


% Initialize mask with zeros
mask = zeros(imageSize);

% Bresenham's line algorithm
x1 = round(point1(1));
y1 = round(point1(2));
x2 = round(point2(1));
y2 = round(point2(2));

dx = abs(x2 - x1);
dy = abs(y2 - y1);

sx = sign(x2 - x1);
sy = sign(y2 - y1);

err = dx - dy;

while true
    mask(y1, x1) = 1; % Set the pixel in the mask

    if x1 == x2 && y1 == y2
        break;
    end
    e2 = 2 * err;
    if e2 > -dy
        err = err - dy;
        x1 = x1 + sx;
    end
    if e2 < dx
        err = err + dx;
        y1 = y1 + sy;
    end
end

end
