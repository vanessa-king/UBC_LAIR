function [data, header]=flat2matrix(flat)
%FLAT2MATRIX Transform FLAT data into a matrix
%   Edited by Vanessa, Jan 2025
%   [DATA, LABELS, UNITS, S] = FLAT2MATRIX(FLAT) transforms the N
%   dimensional FLAT data into a matrix and creates axis vectors for a flat
%   structure. 
%
%   DATA{1} contains the data in an N dimensional matrix
%   DATA{2} contains the coordinate vector for the first dimension
%   DATA{3} contains the coordinate vector for the second dimension
%   ...
%   DATA{N+1}  contains the coordinate vector for dimension N
%
%   LABEL{x}   contains the Label of the corresponding datafield
%   UNIT{x}    contains the Unit of the corresponding datafield
%
%   S(Dim,FwBw) contains the number of data points in dimension Dim
%       FwBw=1 whole size
%       FwBw=2 forward only
%       FwBw=3 backward only (zero for non mirrored axes)
%
%   Try PERMUTE If you have trouble with the order of the matrix dimensions.
%
%See also FLAT_TOOLBOX, FLAT_PARSE, PERMUTE.

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


%get axis vectors, names and units
[axis_tics s]=flat_axes(flat.axis);
axis_name={flat.axis.name};
axis_unit_name={flat.axis.unit_name};

%sort the axes according to the hierarchy...
%get axis order
hierarchy=flat_axes_hirarchy(flat.axis);
%sort axes
axis_tics={axis_tics{hierarchy}};
s=s(hierarchy,:);
axis_name={axis_name{hierarchy}};
axis_unit_name={axis_unit_name{hierarchy}};

%calculate the sample count for each axis
dimensions=[];
for axis=axis_tics,
    dimensions=[dimensions length(axis{1})];
end

%Reshape the data
%Fill bricklet with NaNs to ease reshaping...
phys_data=[flat.phys_data; ones(flat.bricklet_size-flat.data_count,1)*NaN];
%Reshape data...
if(length(dimensions)>1), %reshape complains if it has nothing to do therefore we avoid calling it for 1D
    phys_data=reshape(phys_data,dimensions);
end
       
%return data, labels and units...
data={phys_data, axis_tics{:}};
header.labels={flat.channel_name, axis_name{:}};
header.units={flat.channel_unit, axis_unit_name{:}};
header.size=s;
    
