function [comment] = clickForSpectrum(didv, V_reduced, imageV, offset, n, pointsList)
% CLICKFORSPECTRUM Select points and plot spectra
%Creates a GUI window where you can select a point(s), then it plots the spectra from that point(s). 
%   Plots a 2D slice of the didv data at the closest value of V_reduced to 
%   the set value imageV. From this figure up to n points can be selected 
%   by clicking on the 2D image. For the selected points the spectra didv(V) 
%   are plotted. 
%
% Edited: James Day Jan 2025; M. Altthaler 05/2024; Vanessa 2023
%
%   OPT TBD:    make function accept a list of point coordinates to be
%               plotted. This feature is untested! (05/2024)
%
% Arguments:
%   didv, V_reduced, imageV, offset, n, pointsList as before
%
% This function plots a 2D slice of the dI/dV data (didv) at a specified 
% bias voltage (imageV). The user can select up to n points on this 2D 
% slice, and for each selected point, the corresponding dI/dV spectrum is 
% plotted. The function returns a log comment string containing the 
% coordinates of the selected points.
%
% No code modifications have been made, only additional comments have been added.
% The original commenting style and content are preserved as much as possible.
% Additional comments are provided below in a similar style to clarify the 
% functionality and flow of the code.
%
% Note: 
% - The argument 'pointsList' can be used to provide predetermined points 
%   instead of interacting with the figure.
% - If the user presses Enter early or clicks outside the image boundaries, 
%   the code handles these scenarios gracefully.
% - Colors for each point are chosen from a predefined set, cycling through 
%   'rgbcmyk'.

arguments
    didv        {mustBeNumeric}          % 3D array (x,y,V) with dI/dV data
    V_reduced   {mustBeVector}           % Vector of reduced bias voltages
    imageV      {mustBeNumeric}          % Chosen bias voltage for slice display
    offset      {mustBeNumeric} = 0      % Vertical offset between spectra
    n           {mustBePositive, mustBeInteger} = 2  % Number of points to select
    pointsList  {mustBeNumeric} = []     % Optional predefined list of points (x,y)
end

% Prepare log comment with input parameters
comment = sprintf("DataIn: dataset = grid, variableIn1 = dIdV, variableIn2 = V_reduced; clickForSpectrum(imageV=%.2f, offset=%.2f, n=%d) | ", imageV, offset, n);

% Determine which slice of didv to plot by finding the closest voltage to imageV
[~, imN] = min(abs(V_reduced - imageV)); 
fig_plot = didv(:, :, imN);  % Extract the 2D slice at the chosen voltage

% Create a new figure to display the 2D slice as an image
fig_name = ['dI/dV slice at ', num2str(imageV), ' V'];
img = figure('Name', fig_name);
imagesc(fig_plot); colormap('gray'); hold on;
axis xy; axis image;  % Set axes to normal orientation and equal scaling
title(fig_name);      % Title reflects the chosen bias voltage

% Create a separate figure for the spectra at selected points
spec = figure('Name', 'dI/dV at selected points'); hold on;
xlabel('Bias [V]'); ylabel('dI/dV (a.u.)'); % Label axes for clarity

% Define the radius and coordinates for drawing circles on the image
radius = 2;
xx = -radius:0.01:radius;
yy = sqrt(radius^2 - xx.^2);

% Define a set of colors to differentiate multiple selected points
colours = 'rgbcmyk';

% If no predefined points are given, interactively select them
if isempty(pointsList)
    % Initialize the pointsList array
    pointsList = zeros(n, 2);
    for k = 1:n
        figure(img);
        disp(['Select point ', num2str(k), ' of ', num2str(n), ' in the figure window.']);
        
        % Attempt to get a point from user clicks
        try
            position = round(ginputAllPlatform(1));
        catch
            % If Enter is pressed early, trim pointsList accordingly
            pointsList = pointsList(1:k-1, :);
            break;
        end

        % Validate that the selected point is within the data range
        if position(1) < 1 || position(2) < 1 || ...
           position(1) > size(didv, 1) || position(2) > size(didv, 2)
            disp("Invalid point selected, please click within the image.");
            continue; % Skip invalid point and prompt again
        end
        
        % Store the valid point
        pointsList(k, :) = position;

        % Choose a color for this point
        cidx = mod(k-1, 7) + 1;
        thisColor = colours(cidx);

        % Draw large circles on the image to highlight the selected area
        plot(position(1) + xx, position(2) + yy, thisColor, 'LineWidth', 1.5);
        plot(position(1) + xx, position(2) - yy, thisColor, 'LineWidth', 1.5);

        % Draw a small open circle at the exact selected pixel
        % This indicates the exact (x,y) coordinate chosen
        plot(position(1), position(2), 'o', 'MarkerEdgeColor', thisColor, 'MarkerFaceColor', 'none', 'LineWidth', 1.5);

        % Append the chosen point to the log comment
        comment = strcat(comment, sprintf("(%d,%d), ", position(1), position(2)));

        % Plot the corresponding spectrum in the 'spec' figure
        % Offset is applied to separate multiple spectra vertically
        figure(spec);
        plot(V_reduced, squeeze(didv(position(1), position(2), :)) + (k-1)*offset, thisColor, 'LineWidth', 1.5);
    end
else
    % If pointsList is provided, plot those points without user interaction
    for k = 1:size(pointsList, 1)
        position = pointsList(k, :);

        cidx = mod(k-1, 7) + 1;
        thisColor = colours(cidx);

        figure(img);
        % Draw large circles to indicate the area of interest
        plot(position(1) + xx, position(2) + yy, thisColor, 'LineWidth', 1.5);
        plot(position(1) + xx, position(2) - yy, thisColor, 'LineWidth', 1.5);

        % Draw a small open circle to mark the exact chosen point
        plot(position(1), position(2), 'o', 'MarkerEdgeColor', thisColor, 'MarkerFaceColor', 'none', 'LineWidth', 1.5);

        % Update the comment with this point's coordinates
        comment = strcat(comment, sprintf("(%d,%d), ", position(1), position(2)));

        figure(spec);
        % Plot the spectrum at the given point, applying the vertical offset
        plot(V_reduced, squeeze(didv(position(1), position(2), :)) + (k-1)*offset, thisColor, 'LineWidth', 1.5);
    end
end
end
