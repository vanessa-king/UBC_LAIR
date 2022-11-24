function [m, s, d] = flat_axes(axis)
%[M S D]= FLAT_AXES(FLAT.AXIS) creates a cell array with the coordinate vectors 
%for all axes described in the FLAT.AXIS hierarchy description.
%
%M contains the coordinate vectors
%
%S(Dim,FwBw) contains the number of data points in dimension Dim
%   FwBw=1 whole size
%   FwBw=2 forward only
%   FwBw=3 backward only (zero for not mirrored axes)
%
%D contains scan direction vectors for each coordinate (1=forward -1=backward)
%
%(D or S can be used to split data associated with mirrored axes)
%
%
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

for i=1:length(axis),
    %create coordinate vector
    m{i}=((0:axis(i).clockcount-1)' * axis(i).phys_inc) + axis(i).phys_start;
    d{i}=ones(axis(i).clockcount,1);
    if(axis(i).mirrored) %mirror coordinates
            m{i}=[m{i}(1:axis(i).clockcount/2); m{i}(axis(i).clockcount/2:-1:1)];
            d{i}=[ones(axis(i).clockcount/2,1); -ones(axis(i).clockcount/2,1)];
    end

    %create size matrix 
    s(i,1)=axis(i).clockcount;
    if(axis(i).mirrored),
        s(i,2)=axis(i).clockcount/2;
        s(i,3)=axis(i).clockcount/2;
    else
        s(i,2)=axis(i).clockcount;
        s(i,3)=0;
    end
end

%process tablesets
%create list of potentially triggered coordinate indices
for i=1:length(axis),
    axis(i).triggered=ones(axis(i).clockcount,1);
end
%sort out untriggered indices
%look on each axis for tablesets
for i=1:length(axis)
    if(axis(i).tablesetcount), %if more than 0 tablesets
        for tableset=axis(i).tableset, %process each tableset
            table=zeros(axis(tableset.trigger_index).clockcount,1); %set all to untriggered
            for interval=tableset.interval, %collect all intervals
                table(interval.start:interval.step:interval.stop)=1; %set the triggers for the interval
            end
            %if triggered before and triggered here then trigger = true
            axis(tableset.trigger_index).triggered=...
                axis(tableset.trigger_index).triggered&table;
        end
    end
end
%create effective tablesets and apply them
for i=1:length(axis)
    table=find(axis(i).triggered); %create effective tableset trom triggerlist
    %use talbe to select the relevant coordinates
    m{i}=m{i}(table);
    d{i}=d{i}(table);    
    %update size matrix to account for changes caused by the table
    s(i,1)=length(table);
    s(i,2)=length(find(table<=axis(i).clockcount/2));
    s(i,3)=length(find(table>axis(i).clockcount/2));
end


