function flat_sliceplot(flat, select, Sx, Sy, Sz)
%FLAT_SLICEPLOT(FLAT,SELECT,Sx,Sy,Sz)
%   creates a sliceplot from a flat structure with 3D data. 
%
%   SELECT = [x y z] defines which fraction of the data to convert.
%       If the corresponding axis is not mirrired the value is ignored.
%       If the axis is mirrored:
%            1 exports both directions
%            2 exports the trace
%            3 exports the retrace
%           
%See slice for information on Sx,Sy and Sz
%
%See also FLAT_TOOLBOX, SLICE, FLAT_PARSE.

a=flat2matrix3d(flat,select);
flat_m_sliceplot(a, Sx, Sy, Sz);
colorbar;
