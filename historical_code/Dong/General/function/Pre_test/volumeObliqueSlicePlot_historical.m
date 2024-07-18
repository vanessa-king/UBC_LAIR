function [surfPlot, B,x,y,z, comment] = volumeObliqueSlicePlot(dataCube, point, theta, phi, plotPointBool)
% display an oblique slice defined by a point and normal vector 
%   An oblique slice of the dataCube through the point. The orientation of 
%   the slice is defined by it's normal vecotor in spherical coordinates 
%   (theta, phi in deg). The slice is planar and interpolates values based
%   on the closest datapoints in dataCube. plotPointBool enables (disbales) 
%   the plot of the point and normalvector. 
%   
%   arguments:
%   dataCube        I(V), dIdV, ... data form a grid in the format data(x,y,z) 
%   point           (x,y,z) coordinates of the point, defaults to the center of 
%                   dataCube
%   theta           angle vs. 3rd dim (z-axis): [0, 180]
%   phi             angle vs. 1st dim (x-axis): [0, 360] .

%   plotPointBool   1: plots point and normal vector, else: not
%
%   returns:
%   surfPlot    surf plot of slice (to be checked if the figue should be returned
%               insted?)
%   [B,x,y,z]   slice and it's carthesian coordinates (see obliqueslice)
%   comment     LOG comment

% requiers Image Processing Toolbox

% Feb. 2024, Markus Altthaler

arguments
    dataCube    
    point           {mustBeNumeric} = size(datacube)./2
    theta           {mustBeNumeric} = 0
    phi             {mustBeNumeric} = 0
    plotPointBool   {mustBeNumeric} = 1
end
    
    comment = sprintf('volumeObliqueSlicePlot(dataCube = [%d, %d, %d], point = [%d, %d, %d], theta = %d, phi = %d)', size(dataCube,1),size(dataCube,2),size(dataCube,3),point(1),point(2),point(3),theta,phi);
    
    % Convert spherical coordinates to Cartesian coordinates for the normal vector
    nx = sind(theta) * cosd(phi);
    ny = sind(theta) * sind(phi);
    nz = cosd(theta);
    % Normalize the normal vector
    normal = [nx, ny, nz] / norm([nx, ny, nz]);

    %create the slice using the predef. function obliqueslice (requires
    %Image Processing Toolbox)
    [B,x,y,z] = obliqueslice(dataCube,point,normal);

    %actual plot & parameters for the figure
    figure()
    axis xy
    surfPlot = surf(x,y,z,B,'EdgeColor','None','HandleVisibility','off');
    grid on
    colormap(gray)
    xlabel('x-axis')
    ylabel('y-axis');
    zlabel('z-axis');
    title('Slice in 3-D Coordinate Space')

    xlim([1 size(dataCube,1)]);
    ylim([1 size(dataCube,2)]);
    zlim([1 size(dataCube,3)]);
    
    %optional: plot the point and normal vector
    if plotPointBool == 1
        hold on
        plot3(point(1),point(2),point(3),'or','MarkerFaceColor','r');
        plot3(point(1)+[0 normal(1)],point(2)+[0 normal(2)],point(3)+[0 normal(3)], '-b','MarkerFaceColor','b');
        hold off
        legend('Point in the volume','Normal vector')
    end
    

end
