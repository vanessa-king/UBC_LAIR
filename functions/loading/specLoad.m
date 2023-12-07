function [header, data, channels, comment] = specLoad(folder,stamp_project,spec_number)
% loaddat  Nanonis DAT ASCII file loader
%   [header, data, channels] = loaddat(fn) reads a Nanonis 
%   DAT ASCII file fn.
%   fn: path of the .dat file to read.
%   header: header info of the data file.
%   data: contains the data of all channels, each column in the
%       data array corresponds to an acquired channel.
%   channels: contains the names of the data channels.

% generate log comment 
comment = sprintf("specload(folder=%s, stamp_project=%s, spec_number=%s)|", folder, stamp_project, spec_number);

datfile = strcat(folder,"/",stamp_project,spec_number,".dat");
fn= datfile;

data=''; header=''; channels='';

if exist(fn, 'file')
    fid = fopen(fn, 'r', 'ieee-be');    % open with big-endian
else
    fprintf('File does not exist.\n');
    return;
end

% read header data
% The header consists of key-value pairs, separated by a tab character
% e.g. Settling time (s)	200E-6	
% The beginning of the data block starts with [DATA]
while 1
    s = strtrim(fgetl(fid));
    if strcmp(upper(s),'[DATA]')
        break
    end
    
    %s1 = strsplit(s,char(9));  % not defined in older Matlab versions
    s1 = strsplit_i(s,char(9));
    s1_s = prod(size(s1));
    if s1_s > 0 % line contains a tab
        s_key = strrep(lower(s1{1}), ' ', '_');
        s_val = '';
        if s1_s > 1
            s_val = strrep(s1{2}, '"', '');
        end
        
        s_key = regexprep(lower(s_key), '[^a-z0-9_]', '_');
        header.(s_key) = s_val;
    end
end

% read the channel names
s = strtrim(fgetl(fid));
%channels = strsplit(s,'=');  % not defined in older Matlab versions
channels = strsplit_i(s,char(9));

% read the data
data = fscanf(fid, '%f', [prod(size(channels)) Inf]);
data = transpose(data);

fclose(fid);
end


function s = strsplit_i(str, delim)
    s = {};
    while ~isempty(str),
        [t,str] = strtok(str, delim);
        s{end+1} = t;
    end
end

