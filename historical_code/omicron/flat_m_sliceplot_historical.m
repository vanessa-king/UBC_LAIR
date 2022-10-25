function flat_m_sliceplot(a, Sx, Sy, Sz)
%FLAT_M_SLICEPLOT(M,Sx,Sy,Sz)
%   creates a sliceplot from the 3D data in matrix structure M. 
%
%See slice for information on Sx,Sy and Sz
%
%See also FLAT_TOOLBOX, SLICE, FLAT2MATRIX3D.

slice(a.x,a.y,a.z,permute(a.v,[3 2 1]),Sx,Sy,Sz);
xlabel([a.label.x ' [' a.unit.x ']']);
ylabel([a.label.y ' [' a.unit.y ']']);
zlabel([a.label.z ' [' a.unit.z ']']);
title([a.label.v ' [' a.unit.v ']']);
colorbar;