function [permuted_forward,permuted_backward] = sxmPermute(channel_forward, channel_backward, scan_direction)
%Permutation operation for all channels in a 'sxm' file
%   Permutes a channel from a sxm file so that its orientation matches what
%   we see as a user in Nanonis.
% Input: 
%   channel_forward: array, channel variable in the forward scan direction
%   channel_backward: array, channel variable in the backward scan direction
%   scan_direction: string, whether the scan was made 'Up' or 'Down'
% Output: 
%   permuted_forward: array, the forward variable permuted
%   permuted_backward: array, the backward variable permuted


arguments
    channel_forward
    channel_backward 
    scan_direction      {mustBeText}
end


%no transformation necessary for UP-FORWARD
permuted_forward = channel_forward;

%transformation for UP-BACKWARD
permuted_backward = flip(channel_backward,1);

if scan_direction == "down"
    %transformation for DOWN-FORWARD
    permuted_forward = flip(permuted_forward,2);
    %transformation for DOWN-BACKWARD
    permuted_backward = flip(permuted_backward,2);
end

end