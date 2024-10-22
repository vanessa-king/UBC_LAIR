function [topo, comment] = load_topo_Nanonis(folder, topoFileName)
%Wrapper function for loading topos from Nanonis
%   Uses the Nanonis-made loadsxm.m function, processes all the data into a structure
%   Known possible channels: 'Z', 'Current', and 'LI_D1_X_1_omega'.
%   One extra channel of unknown name will be saved as 'other_channel'.
%   This is a temporary solution. Best practice is to add appropriate names 
%   for any additional channels into the Extract Channels if blocks.
% Input: 
%   folder: string of folder containing data
%   topoFileName: string of the fileName including the extension
% Output: 
%   topo: structure containing all the topo associated data
%   comment: string containing log comment


arguments
    folder          {mustBeText}
    topoFileName    {mustBeText}
end

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Never plot data (e.g. the whole gird) in the comment, only plot the values
%('=<VARn_value>') of variables that decide/affect how the function
%processes data (e.g. order of fit, ...) 
%Note convert all <VARn_value> to strings; 
comment = sprintf("load_topo_Nanonis(folder=%s, topoFileName=%s)|", folder, topoFileName);

%regular function processing:

loadStr = strcat(folder,'/',topoFileName);
%load the raw sxm data:
[header, raw_data] = loadsxm(loadStr);

%Return the entire header, in case we need it
topo.header = header;

%Calculate the x and y values from the header
x_range = header.scan_range(1); %in m
y_range = header.scan_range(2); %in m
x_range = x_range * 1e9; %convert m to nm
y_range = y_range * 1e9; %convert m to nm
number_x_points = header.scan_pixels(1);
number_y_points = header.scan_pixels(2);
topo.x = transpose(linspace((-x_range/2.0), (x_range/2.0), number_x_points));

if topo.header.scan_dir == "up" %y direction is positive
    y_all = transpose(linspace((-y_range/2.0), (y_range/2.0), number_y_points));
elseif topo.header.scan_dir == "down" %y direction is negative
    y_all = transpose(linspace((y_range/2.0), (-y_range/2.0), number_y_points));
else
    fprintf('Invalid scan direction in header.\n');
    return
end


%Get the center position of the topo (in m)
topo.x_position = header.scan_offset(1);
topo.y_position = header.scan_offset(2);

%Get the available channels of data
channels = topo.header.data_info{:,'Name'};
number_channels = height(topo.header.data_info);

% Reshape the raw data by channel and direction. Assumption is that both
% directions are taken, and so there is 2 images per channel
data = reshape(raw_data,[number_x_points,number_y_points,number_channels * 2]);


%This section is to determine if we have a partial image and remove NaN
%values if so. Note that this wasn't necessary for x since it's always full

%find y pixels where there is data
for channel = 1:number_channels
    if channels(channel) == "Z"
        z_all = data(:,:,channel);
    end
end
[~, y_coordinates] = find(~isnan(z_all));


%first check if the topo is finished 
if ~any(isnan(z_all),'all') %we have a full topo
    topo.y = y_all;
    % Extract out the channels
    for channel = 1:number_channels
        if channels(channel) == "Z"
            topo.z = data(:,:,channel);
            topo.z_backward = data(:,:,channel+1);

            %Apply orientation transformation
            topo.z = permute(topo.z, [2 1 3]);
            topo.z_backward = permute(topo.z_backward, [2 1 3]);
            topo.z_backward = flip(topo.z_backward,2);

        elseif channels(channel) == "Current"
            topo.I = data(:,:,channel);
            topo.I_backward = data(:,:,channel+1);

        elseif channels(channel) == "LI_D1_X_1_omega"
            topo.lock_in = data(:,:,channel);
            topo.lock_in_backward = data(:,:,channel+1);

        else
            topo.other_channel = data(:,:,channel);
            topo.other_channel_backward = data(:,:,channel+1);
        end
    end

else % we have an unfinished topo
    topo.y_all = y_all;
    topo.y = topo.y_all(1:max(y_coordinates)-1);
    %Extract out the channels
    for channel = 1:number_channels
        if channels(channel) == "Z"
            topo.z_all = data(:,:,channel);
            topo.z = topo.z_all(:, 1:max(y_coordinates)-1);

            topo.z_backward_all = data(:,:,channel+1);
            topo.z_backward = topo.z_backward_all(:, 1:max(y_coordinates)-1);

        elseif channels(channel) == "Current"
            topo.I_all = data(:,:,channel);
            topo.I = topo.I_all(:, 1:max(y_coordinates)-1);

            topo.I_backward_all = data(:,:,channel+1);
            topo.I_backward = topo.I_backward_all(:, 1:max(y_coordinates)-1);

        elseif channels(channel) == "LI_D1_X_1_omega"
            topo.lock_in_all = data(:,:,channel);
            topo.lock_in = topo.lock_in_all(:, 1:max(y_coordinates)-1);

            topo.lock_in_backward_all = data(:,:,channel+1);
            topo.lock_in_backward = topo.lock_in_backward_all(:, 1:max(y_coordinates)-1);

        else
            topo.other_channel_all = data(:,:,channel);
            topo.other_channel = topo.other_channel_all(:, 1:max(y_coordinates)-1);

            topo.other_channel_backward_all = data(:,:,channel+1);
            topo.other_channel_backward = topo.other_channel_backward_all(:, 1:max(y_coordinates)-1);
        end
    end
end


end