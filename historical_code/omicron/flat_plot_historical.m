function flat_plot(f)
%FLAT_PLOT(FLAT) creates simple plots of 1D, 2D and 3D flat data.
%
% Try: "flat_plot(flat_parse)"
%
% See also FLAT_TOOLBOX, FLAT_PARSE.

switch f.axis_count
    case 1
        flat_m_plot(flat2matrix1d(f));
    case 2
        disp('Plotting trace up only. Please look at flat_plot.m and choose your preferred plotting method for 2D data.');

% Please uncomment one of the following blocks and comment the other blocks:        
        
  % Plot only trace up
        flat_m_surfplot(flat2matrix2d(f,[2 2]));
       %   % alternative: plot flattened data 
       %   flat_m_pcolor(flat_m_polyflat(flat2matrix2d(f,[2 2])));

%   % Plot all images        
%         subplot(2,2,1)
%         flat_m_pcolor(flat2matrix2d(f,[2 2]));
%         subplot(2,2,2)
%         flat_m_pcolor(flat2matrix2d(f,[3 2]));
%         subplot(2,2,3)
%         flat_m_pcolor(flat2matrix2d(f,[2 3]));
%         subplot(2,2,4)
%         flat_m_pcolor(flat2matrix2d(f,[3 3]));
         
    case 3
         disp('Surfplot of first line. Please look at flat_plot.m and choose your preferred plotting method for 3D data.');

% Please uncomment one of the following three blocks and comment the other two blocks:

% % Sliceplot:
%         disp('Please consider using flat_sliceplot directly. The planes often miss the datavolume. 3D data is usually best plotted manually.');
%         flat_sliceplot(f,[2 2 2],0,0,0); % 0,0,0 = slice positions

% Surfplot of first "spectroscopy line"
m=flat2matrix3d(f,[1 1 1]);
m.y=m.z;
m.label.y=m.label.z;
m.unit.y=m.unit.z;
m.z=m.v(:,:,1);
m.label.z=m.label.v;
m.unit.z=m.unit.v;
flat_m_surfplot(m);

% %Scatterplot of data (slow on some systems)
%        flat_m_scatterplot(flat2matrix3d(f,[1 1 1])); 
%         %scatter3 is nicer to visualize the measured data but it is
%         %extremely slow on some systems.

    otherwise
        error('Only 1D, 2D and 3D supported for direct plotting');
end
shg