function fig=flat_m_image(a)
%FLAT_M_IMAGE(M)
%   creates an imageplot from the 2D data in matrix structure M. 
%   Please ba aware that the image plot always uses linear axes!
%   Use FLAT_M_PCOLOR for data with nonlinear axes.
%
%See also FLAT_TOOLBOX, FLAT_M_PCOLOR, FLAT2MATRIX2D.

fig=imagesc(a.x,a.y,a.z); 
xlabel([a.label.x ' / ' a.unit.x '']);
ylabel([a.label.y ' / ' a.unit.y '']);
title([a.label.z ' / ' a.unit.z '']);
colorbar;