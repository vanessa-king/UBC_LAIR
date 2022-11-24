%% Simple FLAT file reading
% This is an example for the FLAT Toolbox. It reads a force curve from the 
% example FLAT file, plots the data and does some calculation.
%

%% Read the flat file
% The function flat_parse reads a flat file and stores its contents in a
% structure. Here the content of 'example.flat' is stored in _f_. You can
% omit the filename to get a file selection dialog.
f=flat_parse('example.flat');

%% Look at the flat data
% The data in _f_ is still in the flat format which is difficult to 
% analyze. The variable axis_count in _f_ tells you the number of 
% dimensions for your data. With the following command you can check the
% dimension if you don't know what the content of the file is.
f.axis_count

%% Prepare the flat data for analysis
% The flat2matrix functions provide access to the data in form of
% n-dimensional matrices. These functions interpret a flat structure and
% return the measured data including the corresponding coordinates. There
% are different commands depending on the number of dimensions: 
%
% * 1D - |flat2matrix1d|
% * 2D - |flat2matrix2d|
% * 3D - |flat2matrix3d|
% * nD - |flat2matrix| (should work with all files)
% 
% Here we have 1D data therefore we use |flat2matrix1d|. This gives us the
% measured values _m.y_ and the corresponding coordinates _m.x_. 
% As you can see below the returned structure _m_ also includes the
% corresponding labels and units.
m=flat2matrix1d(f)


%% Plot the data
% To create a plot of the data you can use the plot function. Here the
% measured force curve data _m.y_ is plotted versus the coordinate _m.x_.  
plot(m.x,m.y)

%%%
% Optionally we can use the text in _m.label.x_ and _m.unit.x_ to 
% label the axes.
xlabel( [m.label.x ' / ' m.unit.x] )
ylabel( [m.label.y ' / ' m.unit.y] )


%% Convenience
% For convenience the previous plot can be created using a single
% function. Please see |help flat_toolbox| for other |flat_m_...| functions
% which can deal with data in matrix form. Especially for 2D data there are more
% functions available.
flat_m_plot(m)


%% Do the same with 2D data
% Read the file
f2d=flat_parse('2d_example.Z_flat');

%%
% Convert data to matrix form. 
% (|[2 2]| Selects the data for "Trace" of x and y. 
% See help |flat2matrix2d| for more information.)
% 
m2d=flat2matrix2d(f2d,[2 2]);

%%
% Plot the data using a pseudo color plot.
% (Please see |help flat_toolbox| for other plot types.)
flat_m_pcolor(m2d)

%%%
% Refine axis scaling 
axis equal
axis tight


%% Advanced data analysis

%% Look at experiment parameters
% The experiment parameters are stored in the flat structure. 
% The structure element "info.Parameter_List" can be used to show all the
% experiment parameters that were used. For convenient access these
% parameters are also stored under info.Parameter.<Experiment Element
% Name>.<Parameter Name>.
dt=f.info.Parameter.ForceCurve.Raster_Time

%% Look at parts of the data and demonstrate a fitting example

% define an interval
int=2:100;

% choose a direction
dir=1;
% For 1D data the “Trace” is stored in m.y(:,1) 
% and the “Retrace” is stored in m.y(:,2)

% show the data as circles
plot(m.x(int,dir),m.y(int,dir),'o')
xlabel( [m.label.x ' / ' m.unit.x] )
ylabel( [m.label.y ' / ' m.unit.y] )

% calculate linear fit on chosen interval
p=polyfit(m.x(int,dir),m.y(int,dir),1);

%add this fit to the graph.
hold on
plot(m.x,polyval(p,m.x),'r-') %plot the fit with a red line
hold off

%% Replot the data subtracting the fit 
% One could also subtract a reference measurement from another FLAT file.
% The first and last point of the data can be cut away easily by using the 
% 2:end-1 syntax.

plot(m.x(2:end-1,1),m.y(2:end-1,1)-polyval(p,m.x(2:end-1,1)))
xlabel( [m.label.x ' / ' m.unit.x] )
ylabel( [m.label.y ' / ' m.unit.y] )


displayEndOfDemoMessage(mfilename)
