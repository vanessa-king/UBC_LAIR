function [time,comment] = getTimeAxis(pointsPerSweep, Traster)
%GETTIMEAXIS Creates a time axis to plot against didv or i(v)
%   pointsPerSweep = number of points per sweep
%   Traster = seconds per sample

comment = sprintf("getTimeAxis(pointsPerSweep=%s, Traster=%s)|", pointsPerSweep, Traster);

time = (0:pointsPerSweep-1)*Traster;

end
