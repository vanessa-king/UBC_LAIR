function [x, y] = pixelatedContour(sg, opt)
%pixelatedContour Pixelated contour computation.
%   pixelatedContour(SG) computes the pixelated contours of connected 
%   components in the indexed image SG. The indexed image, SG, is an m-by-n
%   array of integers.
%
%   [X, Y] = pixelatedContour(...) returns two 2xM matrix of the coordinates 
%   of the vertices where each column is a segment. Pixelated contours are 
%   drawn with the command plot(X,Y).
%
%   [X, Y] = pixelatedContour(..., OPT) uses OPT as a simplification flag.
%   If OPT is true or 1, coplanar segments with two coincident vertices are
%   merged. This option is useful to accelerate the display of the
%   contours.
%
%   See also demo.

%   Author: Jerome Briot
%   http://www.developpez.net/forums/member.php?u=125006
%   http://www.mathworks.com/matlabcentral/fileexchange/authors/21984
%   Contact: dutmatlab#at#yahoo#dot#fr
%   Revision: 1.0 (06-Dec-2016)
%   Comments:
%

narginchk(1, 2);

if nargin==1
    opt = true;
elseif ~islogical(opt) && ~(isnumeric(opt) && (opt==0 || opt==1))
    error('Last argument must be 0/1 or false/true');
end

% Find pixel differences between two consecutive rows
idx = sg(1:end-1,:) ~= sg(2:end,:);
[i,j] = find(idx);

% Compute the vertices of the horizontal segment between two different pixels
y = [i+0.5 i+0.5];
x = [j-0.5 j+0.5];

% Find pixel differences between two consecutive columns
idx = sg(:,1:end-1) ~= sg(:,2:end);
[i,j] = find(idx);

% Compute the vertices of the vertical segment between two different pixels
y = [y ; i-0.5 i+0.5].';
x = [x ; j+0.5 j+0.5].';

if opt
    % Simplify pixelated contours
    simplifypixelatedContour;
end

    function simplifypixelatedContour
        % Simplify pixelated contours by merging coplanar segments with two
        % coincident vertices        
        
        % Compute segment orientation (horizontal or vertical)
        o = (x(1,:)-x(2,:))==0;
        
        % Get the number of occurencies of each point in the graph
        [~, ~, n] = unique([x(:) y(:)], 'rows');
        nb = histc(n, 1:max(n));
        nb = nb(n);
        
        nb_points = size(x,2);
        k = 1;
        
        while (1)
            
            if ~isnan(x(2,k)) && nb(2*k)>=2 % Two segments connected
                idx = (x(2,k)==x(1,:) & y(2,k)==y(1,:)) & (o(k)==o); % Keep only complanar segments
                if any(idx) % Merge coplanar segments
                    x(2,k) = x(2,idx);
                    y(2,k) = y(2,idx);
                    x(:,idx) = NaN;
                    y(:,idx) = NaN;
                    continue;
                end
            end
            
            if k==nb_points % Last point reached => stop
                break;
            else
                k = k+1; % Move to the next point
            end
            
        end
        
        % Remove deleted points
        x(:,isnan(x(1,:))) = [];
        y(:,isnan(y(1,:))) = [];
        
    end

end
