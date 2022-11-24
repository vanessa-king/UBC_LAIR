function flat_m_pcolor(a)
%FLAT_M_PCOLOR(M)
%   creates an imageplot from the 2D data in matrix structure M. 
%   This function supports nonlinear axes.
%
%See also FLAT_TOOLBOX, FLAT2MATRIX2D.


pcolor(a.x,a.y,a.z); 
shading flat;
xlabel([a.label.x ' / ' a.unit.x '']);
ylabel([a.label.y ' / ' a.unit.y '']);
title([a.label.z ' / ' a.unit.z '']);
colorbar;
