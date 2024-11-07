function [masks, comment] = gridDirectionalMask(data, width)
%Average grid along a given direction 
%
% Arguments:
%   data        2D or 3D array containing the data.
%   width       Width of the perpendicular lines for averaging.
%
% Returns:
%   masks       Cell array of logical masks, one for each perpendicular line.
%   comment     Comment for logging the function call.
%
% August 2024 - Dong Chen
%
% Example:
%   [masks, comment] = gridDirectionalAverage(data, 10);
%   This creates perpendicular line masks for directional averaging.

arguments
    data
    width (1,1) {mustBeNumeric, mustBePositive}
end

% Get the main line L using gridMaskLineSegment
[mainMask, mainComment, startPoint, endPoint, polcoord] = gridMaskLineSegment(data);

if isempty(startPoint) || isempty(endPoint)
    error('Line selection was cancelled or invalid');
end

% Calculate the angle of perpendicular lines (90 degrees = pi/2 radians from original)
perpAngle = mod(rad2deg(polcoord) + 90, 360);

% Calculate the vector of the main line
mainVector = endPoint - startPoint;
lineLength = round(norm(mainVector));

% Initialize cell array for masks
masks = cell(lineLength, 1);

% Calculate points along the main line
for i = 0:lineLength-1
    % Get point along main line
    t = i / (lineLength - 1);
    currentPoint = round(startPoint + t * mainVector);
    
    % Calculate endpoints for perpendicular line
    halfWidth = width / 2;
    [perpMask, ~] = gridMaskLineSegment(data, currentPoint, [], [width, perpAngle]);
    
    masks{i+1} = perpMask;
end

% Create comment for logging
comment = sprintf('gridDirectionalAverage(datasize:%s x %s, width:%d)|%s', ...
    mat2str(size(data,1)), mat2str(size(data,2)), width, mainComment);

end
