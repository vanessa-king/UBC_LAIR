function [time] = getTimeAxis(pointsPerSweep, Traster)
%GETTIMEAXIS Creates a time axis to plot against didv or i(v)
%   pointsPerSweep = number of points per sweep
%   Traster = seconds per sample

time = (0:pointsPerSweep-1)*Traster;

end
