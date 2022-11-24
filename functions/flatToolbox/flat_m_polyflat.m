function z=flat_m_polyflat(z,degree,showfitlines,xindex,yindex)
% MF=FLAT_M_POLYFLAT(M [,DEG [,SHOWFITLINES [,xindex,yindex] ] ] )
% flattens the z-Matrix of M using a polynomial plane. 
%
% If DEG is given it defines the order of the polynomes. (Default: DEG=1)
%
% If SHOWFITLINES~=0 a plot is generated to control the quality of the fit.
%
% The plane is fitted to two crossections through the center of the matrix
% as indicated by the plot.
% xindex and yindex can be uses to define the positions of the fit lines.
%
% See also FLAT_TOOLBOX, FLAT2MATRIX2D, FLAT_M_PCOLOR, FLAT_M_SURFPLOT.


if nargin < 2, degree=1; end
if nargin < 3, showfitlines=0; end

if nargin < 5,
    yindex=round(size(z.z,1)/2);
    xindex=round(size(z.z,2)/2);
end

i = find(~isnan(z.z(yindex,:)')); 
px=polyfit(z.x(i),z.z(yindex,i)',degree);
i = find(~isnan(z.z(:,xindex))); 
py=polyfit(z.y(i),z.z(i,xindex),degree);
if showfitlines,
    %show fitlines
    flat_m_surfplot(z);
    hold on;
    plot3(z.x,z.y(yindex)*ones(size(z.x)),polyval(px,z.x),'-o'); 
    plot3(z.x(xindex)*ones(size(z.y)),z.y,polyval(py,z.y),'-o'); 
    hold off;
    shg
end

for iy=1:size(z.y),
    subplane(:,iy)=polyval(px,z.x)+polyval(py,z.y(iy))-py(end);
end
z.z=z.z-subplane';
