function pos = ginputAllPlatform(n)
%GINPUTALLPLATFORM Prompts the user to select points in the current figure window.
%THIS IS AN EQUIVALENT VERSION OF `GINPUT` BUT SUITS BETTER WITH MORE PLATFORMS
%   option 1: input number of clicks: n
%   option 2: click number of points until pressing 'enter key'

%   pos = GINPUTALLPLATFORM(n)
%   pos returns a n-by-2 array containing the x and y coordinates of the selected points.
    
arguments 
    n   {mustBeNumeric, mustBePositive} = []
    
end

    % Initialize the output array
    pos = zeros(n, 2);

    % Create a figure if there is no current figure
    if isempty(gcf)
        figure;
    end
    if  ~isempty(n)
        % Loop to capture N points
        for i = 1:n
            % Display instructions
            disp(['Select point ', num2str(i), ' of ', num2str(n), ' in the figure window.']);
    
            % Wait for a mouse button press
            w=waitforbuttonpress;
            % Get the coordinates of the current point
            currentPoint = get(gca, 'CurrentPoint');

            % Check if the button press is a key press
            if w == 1
                % Get the key that was pressed
                key = get(gcf, 'CurrentCharacter');
                
                % Check if the key is the Enter key (ASCII code 13)
                if double(key) == 13
                    % If Enter key was pressed, terminate the loop
                    pos=pos(1:i-1,:);
                    break;
                end
            end

            pos(i, :) = currentPoint(1, 1:2);
        end
    else
        disp('please click the points on the graph; or exit clicking by pressing the enter key /')
       
    % Start the while loop
        while isempty(n)
            % Wait for a button press
            w = waitforbuttonpress;
            % Get the current point if a mouse click happened
            currentPoint = get(gca, 'CurrentPoint');
            % Check if the button press is a key press
            if w == 1
                % Get the key that was pressed
                key = get(gcf, 'CurrentCharacter');
                
                % Check if the key is the Enter key (ASCII code 13)
                if double(key) == 13
                    % If Enter key was pressed, terminate the loop
                    break;
                end
            else
        
                % Append the current point to the position array
                % pos = [pos; currentPoint];
                pos = [pos; currentPoint(1, 1:2)];
            end
        end
        
    end



end