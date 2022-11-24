function flat_m_plot(a)
%FLAT_M_PLOT(M) creates plots of 1D matrix data in structure M.
%
%See also FLAT_TOOLBOX, FLAT_PARSE, FLAT2MATRIX1D.

plot(a.x,a.y); 
xlabel([a.label.x ' / ' a.unit.x '']);
ylabel([a.label.y ' / ' a.unit.y '']);
