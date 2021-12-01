%
% DESCRIPTION
% This function makes a movie, in which each frame of the movie is a gridmap taken at SOME BIAS. 
%
% PARAMETERS
% clims: are the colour limits, written as [min(didv(:)),max(didv(:))];
%
% didv: vector output of "gridCorrNorm.m"
% Vred: measured biases of didv
% v: a VideoWriter object to write a new Motion JPEG AVI file (defined just before calling this function)(this is optional, giving argument v will save the video)
%

function gridMovie(didv, Vred, v)

if nargin > 2, open(v), end

%
% load colourmap
%

color_scale_resolution = 1000; % 1000 evenly spaced colour points
cm_viridis = viridis(color_scale_resolution); % Default matplotlib (for LAIR)
cm_inferno = inferno(color_scale_resolution);
cm_magma = magma(color_scale_resolution);
cm_plasma = plasma(color_scale_resolution);

%
% create the figures, which become the frames of the movie
%

figure;
for i = 1:size(didv,1)
    clims = [-0.1E-8,1E-8];
    imagesc(flip(permute(squeeze(didv(i,:,:)),[2,1]),1),clims);
    colorbar;
    title(['V = ',num2str(Vred(i)),'V'], 'FontSize',16);
    axis image
      F = getframe(gcf);
    if nargin > 2, writeVideo(v, F), end
end

if nargin > 2, close(v), end

end
