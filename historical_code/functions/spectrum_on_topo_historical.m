function [Biases,comment] = spectrum_on_topo_historical(spectra, z_img, x_position_img, y_position_img)
% spectra_on_topo plot the spectra and labels where the spectra is relative to the topograph. 
%   spectra = name of the spectra 
%   z_img = the topographic image. 
%   x_position_img = the center x position of topo image 
%   y_position_img = the center y position of topo image

arguments
   spectra
   z_img
   x_position_img
   y_position_img
end

comment = sprintf("spectra_on_topo(spectra=%.5s, z_img, x_position_img, y_position_img)|", );

% Define a function to extract specific values from spectra file
function result = spectra_at(spectra)
    % Open the file
    fin = fopen(spectra, 'r');
    % Read the file and extract desired values
    data = textscan(fin, '%f %f %f %f %f %f', 'HeaderLines', 37);
    result = [data{4}(4), data{5}(4), data{6}(4)]; % Extract specific values
    % Close the file
    fclose(fin);
end
% Define a function to calculate dI/dV
function didv = calculate_didv(V, I)
    % Calculate the derivative dI/dV
    dv = V(2) - V(1);
    didv = diff(I) / dv;
end
% Define a function to track and plot didv on the topography
function didvTracker(spectra, topo)
    % Load the spectra data
    spectrum = importdata(spectra);
    bias = spectrum.data(:, 1);
    current = spectrum.data(:, 2);
    LIX = spectrum.data(:, 3);
    
    % Load the topography data
    S = importdata(topo);
    Z = S.Z; % Assuming 'Z' channel contains topography data

    % Determine the position on the topography
    pxdata = Z.data;
    pxsize = Z.px; % Assuming 'px' field contains pixel size
    pxnum = size(pxdata, 1);
    center = centeroftopo;
    x = round(pxnum / 2 + (spectra_at(spectra)(1) - center(1)) / pxsize);
    y = round(pxnum / 2 + (spectra_at(spectra)(2) - center(2)) / pxsize);
    % Plot the topography with a red dot at the specified position
    figure;
    imshow(pxdata);
    title(topo);
    hold on;
    plot(x, pxnum - y, 'ro'); % Red dot
    % Plot the spectra
    figure;
    plot(bias, LIX);
    title(spectra);
end
% Call the didvTracker function with specific files
spectraFile = 'PtSn4_4K952.dat';
topoFile = 'PtSn4_Nov341.sxm';
didvTracker(spectraFile, topoFile);