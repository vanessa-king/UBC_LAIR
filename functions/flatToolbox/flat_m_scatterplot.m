function flat_m_scatterplot(a)
%FLAT_M_SCATTERPLOT(M)
%   creates a scatter plot from the 3D data in matrix structure M. 
%
% Note: Large scatterplots tend to render slowly.
% But the scatterplot accepts 3 coordinates and 2 values (One for the
% dotsize and one for the dot color.)
%
%See also FLAT_TOOLBOX, SCATTER3, FLAT2MATRIX3D.

[x y z]=meshgrid(a.x,a.y,a.z);
v=permute(a.v,[3 2 1]);
scatter3(x(:),y(:),z(:),[],v(:)); %I want to tank Dough's Blog for highlighting this nice function!
xlabel([a.label.x ' [' a.unit.x ']']);
ylabel([a.label.y ' [' a.unit.y ']']);
zlabel([a.label.z ' [' a.unit.z ']']);
title([a.label.v ' [' a.unit.v ']']);
colorbar;
