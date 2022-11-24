function m=flat2matrix1d(flat)
%M=FLAT2MATRIX3D(FLAT,SELECT) 
%   transforms the 3 dimensional FLAT data into a matrix and creates axis
%   vectors for a flat structure. 
%
%   M.Y     contains the data in a vector (matrix if axis is mirrored)
%   M.X     contains the coordinate vector for the axis
%
%   M.LABEL.{x}       contains the Label of the corresponding datafield
%   M.UNIT.UNIT{x}    contains the Unit of the corresponding datafield
%
%See also FLAT_TOOLBOX, FLAT_PARSE, FLAT_M_PLOT.

% This file is part of FLAT Toolbox
% Copyright (c) 2009, Christopher Siol, Electronic Materials, 
% Institute of Materials Science, Technische Universität Darmstadt 
% All rights reserved.
%
% FLAT Toolbox is free software: you can redistribute it and/or modify it
% under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or (at
% your option) any later version.
% 
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
% General Public License for more details.
% 
% You should have received a copy of the GNU Lesser General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.


[data,labels,units,s]=flat2matrix(flat); %transform data to matrix

if(length(data)~=2),
    error('Data with 1 axis needed.');
end

if(flat.axis(1).mirrored),
    data{2}=[data{2}(1:s(1,2)) data{2}(s(1,2)+1:end)];%fold axis
    data{1}=[data{1}(1:s(1,2)) data{1}(s(1,2)+1:end)];%fold data
end

m.x=data{2};
m.y=data{1};
m.label.x=labels{2};
m.label.y=labels{1};
m.unit.x=units{2};
m.unit.y=units{1};

