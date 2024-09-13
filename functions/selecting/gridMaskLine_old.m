function [mask, comment, BoundaryPoint1, BoundaryPoint2, polcoord] = gridMaskLine_old(topo, pointA, pointB, polcoord)
%Returns a mask representing a line. 
%   Creates a mask of matching size to the topo image. The line is defined
%   by two points or relative polar coordinates. If the optional parameters
%   pointA, and pointB or polcoord are parsed to the function, the parsed 
%   values define the line. If no defining values are parsed, the function
%   assigns the values via (graphical) user input.

%Input arguments
%   topo        topography image consistant with the grid map
%   pointA      [x1,y1] absolute Carthesian coordinate of point 1 (optional)
%   pointB      [x2,y2] absolute Carthesian coordinate of point 2 (optional)
%   polcoord    [theta] angle of the line, theta is in degrees (optional)

%Output
%   mask        mask of selected area
%   comment     log comment

%   Dec, 2023   Dong Chen


%  add an argument validation
arguments
    topo
    pointA      {mustBeNumeric, mustBePositive}=[]
    pointB      {mustBeNumeric, mustBePositive}=[]
    polcoord    {mustBeNumeric}=[]
end

[~,~,startPoint,endPoint,polcoord]=gridMaskLineSegment(topo,pointA,pointB,polcoord);

%% Find the two Points that sit on the boundary of the topo. 

% Create a box that represents the boundary of the topo 
xlimit = [1 size(topo,1)];
ylimit = [1 size(topo,2)];
xbox = xlimit([1 1 2 2 1]);
ybox = ylimit([1 2 2 1 1]);

% Create a line segment that extend beyond the boundary of the topo
if startPoint(1) == endPoint(1)
    Pt1_beyond=[startPoint(1), ylimit(1)-10];
    Pt2_beyond=[endPoint(1), ylimit(2)+10]; 
else
    k=(startPoint(2)-endPoint(2))/(startPoint(1)-endPoint(1));
    b=(startPoint(2)-k*startPoint(1));
    % This if statement is to address the catastropic case when k is 0 or
    % infinity
    if abs(k)<1
         Pt1_beyond=[xlimit(1)-10,(xlimit(1)-10)*k+b];
         Pt2_beyond=[xlimit(2)+10,(xlimit(2)+10)*k+b];
    else
         Pt1_beyond=[((ylimit(1)-10)-b)/k,ylimit(1)-10];
         Pt2_beyond=[((ylimit(2)+10)-b)/k,ylimit(2)+10];    
    end 
end

line_seg_x = [Pt1_beyond(1), Pt2_beyond(1)];
line_seg_y = [Pt1_beyond(2), Pt2_beyond(2)];

[BoundaryPoints_x, BoundaryPoints_y] = polyxpoly(line_seg_x, line_seg_y, xbox, ybox);
BoundaryPoint1=[round(BoundaryPoints_x(1)),round(BoundaryPoints_y(1))];
BoundaryPoint2=[round(BoundaryPoints_x(2)),round(BoundaryPoints_y(2))];

% display the intersections 
figure()
mapshow(xbox,ybox,'DisplayType','polygon','LineStyle','none')
mapshow(line_seg_x,line_seg_y,'Marker','+')
mapshow(BoundaryPoints_x,BoundaryPoints_y,'DisplayType','point','Marker','o')

% make the mask 
[mask,~] =createLineSegmentMask(size(topo), BoundaryPoint1, BoundaryPoint2);
mask = logical(mask); %set datatype
end