function endPoint = calculateEndPoint(startPoint, r, phi)
%converts polar coordinates to end point for line mask 
%   calculates the poisition [x2,y2], rounded to the next integer values, 
%   of the end point based on the polar coordinates (r and phi) relative 
%   to the given startPoint [x1,y1]. Note all point coordinates must be
%   nonzero positive numbers and will be rounded to the next neares integer.
%   
%   Note: the functions deliberatelty returns 'invalid' (e.g negnative 
%   values) for endPoint, as these are used to treat expections in the top 
%   level function gridMaskLineSegment()

%arguments:
%   startPoint  coordinates of the starting point [x1, y1]
%   r           length of the line
%   phi         angle in degrees 

%returns:
%   endPoint    coordinates of the end point [x2, y2]

% Nov. 2023, M. Altthaler, edited by Jiabin

arguments
    startPoint  {mustBeNumeric,mustBePositive}
    r           {mustBeNumeric,mustBePositive}
    phi         {mustBeNumeric}
end

% Calculate the coordinates of the end point
x2 = round(startPoint(1)) + round(r * cosd(phi));
y2 = round(startPoint(2)) + round(r * sind(phi));

endPoint = [x2, y2];

end
