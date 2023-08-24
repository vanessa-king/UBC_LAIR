function [time, comment] = getTimeAxis(pointsPerSweep, Traster)
% GETTIMEAXIS Creates a time axis to plot against didv or i(v)
%
%  pointsPerSweep = number of points per sweep
%  Traster = seconds per sample
%  time = the generated time axis
%  comment = a formatted comment string

% These are required by the first block in logTest.m and are defined there.
arguments
pointsPerSweep
Traster
end

% Generate the comment
comment = sprintf("getTimeAxis(pointsPerSweep=%s, Traster=%.6f)|", num2str(pointsPerSweep), Traster);

% Generate the time axis
time = (0:pointsPerSweep-1) * Traster;

end
