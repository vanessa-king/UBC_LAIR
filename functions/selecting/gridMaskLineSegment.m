function [mask,comment,startPoint, endPoint, polcoord] = gridMaskLineSegment(topo,pointA, pointB, polcoord)
%Returns a mask representing a line segment. 
%   Creates a mask of matching size to the topo image. The line segment is 
%   defined by the start and end point, or the start point and relative polar
%   coordinates. If the optional parameters pointA, and pointB, or polcoord 
%   are parsed to the function, the parsed values define the line. If no
%   defining values are parsed, the function assigns the values via
%   (graphical) user input.

%Input arguments
%   topo        topography image consistant with the grid map
%   pointA      [x1,y1] absolute Carthesian coordinate of start point (optional)
%   pointB      [x2,y2] absolute Carthesian coordinate of end point (optional)
%   polcoord    [r,theta] polar coordinate of end point relative to start point, theta is in degrees (optional)

%Output
%   mask        mask of selected area
%   comment     log comment

%   Nov. 2023   Jiabin Y., 
%   edited Dec. 2023 Markus Altthaler


%  add an argument validation
arguments
    topo
    pointA      {mustBeNumeric, mustBePositive}=[]
    pointB      {mustBeNumeric, mustBePositive}=[]
    polcoord    {mustBeNumeric, mustBePositive}=[]
end



if isempty(pointA) && isempty(pointB)  && isempty(polcoord)
    % define line via user input points/values
    disp('The line segment for the mask can be defined by:');
    disp('- a start and an end point, selected by clicking in the topo image');
    disp('- a start point, selected by clicking in the topo image, and the lenght and angle of the line segment.')
    method=input('Define the line via two points? Y/N [Y]:', "s");
    if isempty(method)
        method = "Y";
    end

    if method == "Y" || method == "y"
        %define line by two clicks on the image

        % Display an topo image 
        figure()
        p1=image(topo,'CDataMapping','scaled'); 
        axis square
        hold on

        selectedTwoPoints=ginputAllPlatform(2);
        %selectedTwoPoints=ginput(2);
        % define the start point
        startPoint=round(selectedTwoPoints(1,:));
        % define the end point
        endPoint=round(selectedTwoPoints(2,:));

        %draw line on plot
        line([startPoint(1),endPoint(1)],[startPoint(2),endPoint(2)],'Color','red','linewidth', 1.5);
        hold off

        % calculate the polar angle based on the start and end point. 
        v=endPoint-startPoint;
        u=[1 0];
        polcoord=acos(dot(v,u)/norm(v));
    
        comment = sprintf('gridMaskLineSegment(topo: %d x %d, point1=[],point2=[], polcoord=[]), startpoint=[%d,%d], endpoint[%d,%d];', size(topo, 1), size(topo, 2), startPoint(1), startPoint(2), endPoint(1), endPoint(2));
    else
        % click on topo once, and input r and theta

        % theta=0; % horizontal line
        figure()
        p1=image(topo,'CDataMapping','scaled'); 
        axis square
        hold on

        % define the start point
        startPoint=round(ginputAllPlatform(1));
        %startPoint=round(ginput(1));
        

        % define the end point with proper r and theta
        
        % prompt: ask the user to input proper radius & check validity of
        % the vlaue
        radius=input('Please input the value for the length of the line segment:');
        %catch no input:
        if isempty(radius)
            while isempty(radius)
                disp('You missed an input!')
                radius=input('Please input a value for the length of the line segment:');
            end
        end
        % check valid input:
        if ~isnumeric(radius)
            disp('This is not a numeric value!')
            return;
        end
        if radius<=0 
            disp('The length of a line must be positive!')
            return;
        end
        
        %check maximum valid length of line 
        %note: that is the distance to the opposing cornor of the quadrant the point lies within 
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
        end 
        
        % prompt: ask the user to input proper angle
        disp('Specify the angle of the line in degrees (0 is horizontal, 90  degrees is vertical)')
        angle=input('Please input the angle in degrees:');
        %catch no input:
        if isempty(angle)
            while isempty(angle)
                disp('You missed an input!')
                angle=input('Please input the angle in degrees:');
            end
        end
        %check valid input
        if ~isnumeric(angle)
            disp('This is not a numeric value!')
            return;
        end

        %calcualte endpoint and chekc if the endpoint exceeds the image
        endPoint=calculateEndPoint(startPoint, radius, angle);
        
        if endPoint(1) < 1 || endPoint(2) < 1 || endPoint(1) > size(topo, 1) || endPoint(2) > size(topo, 2)
            disp('The endpoint lies beyond the limit of data range');
            endPoint= [];
            return;
        end
        
        %draw line on plot
        line([startPoint(1),endPoint(1)],[startPoint(2),endPoint(2)],'Color','red', 'linewidth', 1.5);
        hold off
        
        % calculate the polar angle based on the start and end point. 
        v=endPoint-startPoint;
        u=[1 0];
        polcoord=acos(dot(v,u)/norm(v));

        comment = sprintf('gridMaskLineSegment(topo: %d x %d, point1=[],point2=[], polcoord=[]), startpoint=[%d,%d], r=%d, theta=%d;', size(topo, 1), size(topo, 2), startPoint(1), startPoint(2), radius, angle);
    end

elseif (~isempty(pointA) && ~isempty(pointB)) || (~isempty(pointA) && ~isempty(polcoord))
    % cases of predefined start and end points (parsed values)
    if (~isempty(pointA) && ~isempty(pointB))
        % use arguments point1 and point2
        startPoint=pointA;
        endPoint=pointB;
        
        % check if the startPoint and endPoint is within the topo image
         if startPoint(1) < 1 || startPoint(2) < 1 || startPoint(1) > size(topo, 1) || startPoint(2) > size(topo, 2)
            disp('The startpoint lies beyond the limit of data range');
            startPoint= [];
            return;
         elseif endPoint(1) < 1 || endPoint(2) < 1 || endPoint(1) > size(topo, 1) || endPoint(2) > size(topo, 2)
            disp('The endpoint lies beyond the limit of data range');
            endPoint= [];
            return;
         end
        
        % calculate the polar angle based on the start and end point. 
        v=endPoint-startPoint;
        u=[1 0];
        polcoord=acos(dot(v,u)/norm(v));
        
        comment = sprintf('gridMaskLineSegment(topo: %d x %d, point1=[%d,%d],point2=[%d,%d], polcoord=[])', size(topo, 1), size(topo, 2), pointA(1), pointA(2), pointB(1), pointB(2));
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
        
        % calculate the polar angle based on the start and end point. 
        v=endPoint-startPoint;
        u=[1 0];
        polcoord=acos(dot(v,u)/norm(v));
        
        comment = sprintf('gridMaskLineSegment(topo: %d x %d, point1=[%d,%d],point2=[], polcoord=[%d,%d])', size(topo, 1), size(topo, 2), pointA(1), pointA(2), polcoord(1), polcoord(2));
    end
else
    disp('the arguments are not properly defined');

end

%actually creating the mask; note: the returned lower level comment is 
%omitted as the log comments that the function returns are assigned above
%based on the use case
[mask,~] =createLineSegmentMask(size(topo), startPoint,endPoint);
mask = logical(mask); %set datatype


end