function m=flat2matrix2d(flat,select)
%M=FLAT2MATRIX2D(FLAT,SELECT) 
%   transforms the 2 dimensional FLAT data into a matrix 
%   and creates axis vectors for a flat structure. 
%
%   M.Z     contains the data in an 2 dimensional matrix
%   M.X     contains the coordinate vector for the first axis
%   M.Y     contains the coordinate vector for the second axis (root axis)
%      
%
%   M.LABEL.{x}   contains the Label of the corresponding datafield
%   M.UNIT.{x}    contains the Unit of the corresponding datafield
%
%   SELECT = [x y] defines which fraction of the data to convert.
%       If the corresponding axis is not mirrored the value is ignored.
%       If the axis is mirrored:
%            1 exports both directions
%            2 exports the trace
%            3 exports the retrace
%
%See also FLAT_TOOLBOX, FLAT_PARSE, FLAT_M_SURFPLOT, 
%         FLAT_M_PCOLOR, FLAT_M_POLYFLAT.

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

if nargin<2,
    select=[2 2];
    disp('Warning Trace Up selected ( select=[2 2] ). Please see help for details');
end

select=select([1 2]); %reorder parameters to make indices fit the axis indices

[data,labels,units,s]=flat2matrix(flat); %transform data to matrix


if(length(data)~=3),
    error('Data with 2 axes needed.');
end


%cut out the selected data
for i=1:2,
    if(flat.axis(i).mirrored),
        switch select(i)
        case 1 %get all=leave as is
            %do nothing
        case 2 %get trace
            data{i+1}=data{i+1}(1:s(i,2));%cut axis
            switch i %cut data (code depends on dimension)
            case 1 
                data{1}=data{1}(1:s(i,2),:);
            case 2
                data{1}=data{1}(:,1:s(i,2));
            end
                
        case 3 %get retrace
            data{i+1}=data{i+1}(s(i,2)+1:end); %cut axis
            switch i %cut data
            case 1
                data{1}=data{1}(s(i,2)+1:end,:);
            case 2
                data{1}=data{1}(:,s(i,2)+1:end);
            end
            
        otherwise
            warning('FLAT:Convert','Illegal selection please choose 1 (both), 2 (trace) or 3 (retrace)');
        end
            
    end
end


m.z=data{1}';
m.x=data{2};
m.y=data{3};
m.label.z=labels{1};
m.label.x=labels{2};
m.label.y=labels{3};
m.unit.z=units{1};
m.unit.x=units{2};
m.unit.y=units{3};

