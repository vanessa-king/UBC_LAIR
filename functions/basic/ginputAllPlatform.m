function pos = ginputAllPlatform(n)
%GINPUTALLPLATFORM Select points from the current figure, compatible across platforms
% This function allows the user to select points in a figure window.
% The user can terminate the selection early by pressing Enter.
%
% Edited: James Day Jan 2025; Jiabin Yu 2024
%
% Arguments:
%   n: (optional) Number of points to select. If not specified or set to 
%      'inf', the user can select points until pressing the Enter key.
%
% This function is designed to be more platform-agnostic than the default ginput.
% It continuously waits for either mouse clicks (to record points) or the Enter 
% key (to finish selecting points early). If the figure is closed unexpectedly, 
% the loop ends gracefully. If n is specified, once that many points are selected, 
% the function stops collecting more points.
%
% The selected points (x,y) are returned in 'pos', an Nx2 matrix, with each row 
% containing the coordinates of one selected point. If no points are selected 
% (e.g., pressing Enter immediately), 'pos' will be empty.
%
% The original comments and functionality have been preserved. Additional 
% comments have been added in the same style to clarify the code flow.

arguments
    n {mustBeNumeric, mustBePositive, mustBeInteger} = inf
end

pos = [];
disp("Click points on the figure. Press Enter to abort.");

% If no figure is currently open, create a new one. This ensures the user
% always has a figure to click on.
if isempty(gcf)
    figure;
end

% Get the current axes handle and ensure that new points remain plotted.
ax = gca;
hold(ax, 'on');

% Main loop to capture user input events (mouse clicks or key presses).
while true
    try
        w = waitforbuttonpress; % Wait for a button press (mouse or keyboard)
    catch
        % If the figure is closed while waiting, exit gracefully.
        disp("Figure closed. Exiting point selection.");
        break;
    end

    if w == 0
        % w == 0 indicates a mouse click event, so record the clicked point.
        currentPoint = get(ax, 'CurrentPoint');
        % Append the newly selected point (x,y) to the pos array.
        pos = [pos; currentPoint(1, 1:2)];

        % If a finite number of points n is specified and reached, stop collecting.
        if size(pos, 1) >= n
            break;
        end
    elseif w == 1
        % w == 1 indicates a key press event.
        key = get(gcf, 'CurrentCharacter');
        % If Enter (ASCII 13) is pressed or no character is retrieved (empty),
        % terminate point selection early.
        if isempty(key) || double(key) == 13
            disp("Point selection terminated early by pressing Enter.");
            break;
        else
            % Any other key press is invalid for this action. Instruct the user
            % on proper usage.
            disp("Invalid key press. Use mouse clicks to select points or press Enter to finish.");
        end
    end
end

% After the loop, report the selected points, if any.
if ~isempty(pos)
    disp("Selected points:");
    disp(pos);
else
    disp("No points selected.");
end
end