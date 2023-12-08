function [mask, startPoint, endPoint, comment] = gridMaskLine(topo, pointA, pointB, polcoord)
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
%   polcoord    [r,theta] polar coordinate of point 1 relative to point 2, theta is in degrees (optional)

%Output
%   mask        mask of selected area
%   comment     log comment

%   Dec, 2023   Dong Chen


%  add an argument validation
arguments
    topo
    pointA      {mustBeNumeric, mustBeInteger}=[]
    pointB      {mustBeNumeric, mustBeInteger}=[]
    polcoord    {mustBeNumeric, mustBePositive}=[]
end


if isempty(pointA) && isempty(pointB)  && isempty(polcoord)
    % define line via user input points/values
    disp('The line for the mask can be defined by:');
    disp('- a start and an end point, selected by clicking in the topo image');
    disp('- a start point, selected by clicking in the topo image, and the lenght and angle of the line.')
    method=input('Define the line via two points? Y/N [Y]:', "s");
    if isempty(method)
        method = "Y";
    end

    if method == "Y" || method == "y"
        % click on topo twice, get two points
        % assign a start point  as startpoint and an end point as endpoint
        % startpoint=[1,1];
        % endpoint=size(topo);

       
        % Display an topo image 
        figure()
        p1=image(topo,'CDataMapping','scaled'); 
        axis square
        selectedTwoPoints=ginput(2);
        % define the start point
        startPoint=round(selectedTwoPoints(1,:));
        % define the end point
        endPoint=round(selectedTwoPoints(2,:));
        comment = sprintf('gridlinemask(topo: %d, point1=[],point2=[], polcoord=[]), startpoint=[%d,%d], endpoint[%d,%d];', size(topo, 1), startPoint(1), startPoint(2), endPoint(1), endPoint(2));
    else
        % click on topo once, and input r and theta
        % assign a start point as startpoint and radius as r, angle as theta
        % startpoint=[1,1];
        % r=size(topo, 1)/2;
        % theta=0; % horizontal line
        figure()
        p1=image(topo,'CDataMapping','scaled'); 
        axis square
        % define the start point
        startPoint=round(ginput(1));
        % define the end point with proper r and theta
        % prompt: ask the user to input proper argument 
        radius=input('Please input the proper length of the line (but since here we are making a line instead of linesegment, you can type any number thats none-zero):');
        
        if isempty(radius)
            while isempty(radius)
                radius=input('You miss an input value here!!!!! radius:');
            end
        end
        if ~isnumeric(radius)
            disp('This is not a numeric value!')
            return;
        end

        if startPoint(1) < size(topo, 1)/2 && startPoint(2) < size(topo, 2)/2
             % disp('Both x and y components of radius are in the (<n/2, <n/2) interval');
             maxRadius = sqrt((size(topo, 1) - startPoint(1))^2 + (size(topo, 2) - startPoint(2))^2);
        elseif startPoint(1) < size(topo, 1)/2 && startPoint(2) >= size(topo, 2)/2
            % disp('x component is in the (<n/2, >=n/2) interval, y component is in the (>=n/2, >=n/2) interval');
            maxRadius = sqrt((size(topo, 1) - startPoint(1))^2 + (startPoint(2))^2);
        elseif startPoint(1) >= size(topo, 1)/2 && startPoint(2) < size(topo, 2)/2
            % disp('x component is in the (>=n/2, <n/2) interval, y component is in the (<n/2, <n/2) interval');
            maxRadius = sqrt((startPoint(1))^2 + (size(topo, 2) - startPoint(2))^2);
        elseif startPoint(1) >= size(topo, 1)/2 && startPoint(2) >= size(topo, 2)/2
            % disp('Both x and y components of radius are in the (>=n/2, >=n/2) interval');
            maxRadius = sqrt((startPoint(1))^2 + (startPoint(2))^2);
        else
            disp('invalid start point');
        end

        
        if radius > maxRadius
            disp('The length of the line exceeds the max length you can choose');
            return;
        else
        end 

        disp('Specify the angle of the line in degrees (0 is horizontal, 90  degrees is vertical)')
        angle=input('Please input the angle in degree:');
        if isempty(angle)
            
            while isempty(angle)
                angle=input('You miss an input value here!!!!! angle:');
            end
        end
        if ~isnumeric(angle)
            disp('This is not a numeric value!')
            return;
        end
        
        endPoint=calculateEndPoint(startPoint, radius, angle);
        
        if endPoint(1) < 1 || endPoint(2) < 1 || endPoint(1) > size(topo, 1) || endPoint(2) > size(topo, 2)
            disp('the endpoint chosed it beyond the limit of data range');
            endPoint= [];
            return;
        end

        comment = sprintf('gridlinemask(topo: %d, point1=[],point2=[], polcoord=[]), startpoint=[%d,%d], r=%d, theta=%d;', size(topo, 1), startPoint(1), startPoint(2), radius, angle);
    end

elseif (~isempty(pointA) && ~isempty(pointB)) || (~isempty(pointA) && ~isempty(polcoord))
    %   move to methods that start and end points are both predefined.
    if (~isempty(pointA) && ~isempty(pointB))
        % use arguments point1 and point2
        startPoint=pointA;
        endPoint=pointB;
        % check if the startPoint and endPoint is within the size 
         if startPoint(1) < 1 || startPoint(2) < 1 || startPoint(1) > size(topo, 1) || startPoint(2) > size(topo, 2)
            disp('the startpoint chosed it beyond the limit of data range');
            startPoint= [];
            return;
         elseif endPoint(1) < 1 || endPoint(2) < 1 || endPoint(1) > size(topo, 1) || endPoint(2) > size(topo, 2)
            disp('the endpoint chosed it beyond the limit of data range');
            endPoint= [];
            return;
         end

        comment = sprintf('gridlinemask(topo: %d, point1=[%d,%d],point2=[%d,%d], polcoord=[])', size(topo, 1), pointA(1), pointA(2), pointB(1), pointB(2));
    else 
        % use arguments point1 and polcoord
        startPoint=pointA;
        endPoint=calculateEndPoint(startPoint, polcoord(1), polcoord(2));
        % check if the startPoint and endPoint is within the size 
         if startPoint(1) < 1 || startPoint(2) < 1 || startPoint(1) > size(topo, 1) || startPoint(2) > size(topo, 2)
            disp('the startpoint chosed it beyond the limit of data range');
            startPoint= [];
            return;
         elseif endPoint(1) < 1 || endPoint(2) < 1 || endPoint(1) > size(topo, 1) || endPoint(2) > size(topo, 2)
            disp('the endpoint chosed it beyond the limit of data range');
            endPoint= [];
            return;
         end
        comment = sprintf('gridlinemask(topo: %d, point1=[%d,%d],point2=[], polcoord=[%d,%d])', size(topo, 1), pointA(1), pointA(2), polcoord(1), polcoord(2));
    end
else
    disp('the arguments are not properly defined');

end

%% Find the startPoint and endPoint that sit on the boundary of the topo. 

% Create a box that represents the boundary of the topo 
xlimit = [1 size(topo,1)];
ylimit = [1 size(topo,2)];
xbox = xlimit([1 1 2 2 1]);
ybox = ylimit([1 2 2 1 1]);

% Create a line segment that extend beyond the boundary of the topo
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
[mask,~] =createLineMask(size(topo), BoundaryPoint1, BoundaryPoint2);




end