function m = flat_axes_hirarchy(axis)
%M = FLAT_AXES_HIRARCHY(FLAT.AXIS) creates an array with the index of the
%axis descriptions in oder of their hirarchy.
%

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

%Assume the first axis in the FLAT description to be the trigger axis for
%the channel 
i=1;

for position=1:length(axis) %do not iterate over more axis descriptions than available
    %step up in axis hirarchy...
    m(position)=i;
    i=axis(i).trigger_index;
    if(i==0), %master axis reached...
        break
    end
end

if(i~=0), %if the for loop ended without reaching the master axis
    warning('FLAT:Axes','Did not find the master axis! There must be something wrong with the axis description.');
end
