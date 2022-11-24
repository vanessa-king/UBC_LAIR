function flat_m_surfplot(a)
%FLAT_M_SURFPLOT(M)
%   creates a surfplot from the 2D data in matrix structure M. 
%
%See also FLAT_TOOLBOX, FLAT2MATRIX2D.

surf(a.x,a.y,a.z); shading flat;
xlabel([a.label.x ' / ' a.unit.x '']);
ylabel([a.label.y ' / ' a.unit.y '']);
zlabel([a.label.z ' / ' a.unit.z '']);
%colorbar;
