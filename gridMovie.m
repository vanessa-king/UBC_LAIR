function gridMovie(didv, Vred, v)
%GRIDMOVIE Summary of this function goes here
%   Detailed explanation goes here

% fmt_mov = zeros(size(didv,2),size(didv,3),1,size(didv,1));
% for kx=1:size(didv,2)
%     for ky=1:size(didv,3)
%         fmt_mov(kx,ky,1,:) = didv(:,kx,ky);
%     end
% end
% fmt_mov = rescale(fmt_mov).*255 + 1;
% mov = immovie(fmt_mov,gray(256));
% implay(mov,3);

if nargin > 2, open(v), end

% load colourmap
m = 1000; % 1000 evenly spaced colour points
cm_viridis = viridis(m); % Default matlibplot
cm_inferno = inferno(m);
cm_magma = magma(m);
cm_plasma = plasma(m);

figure;
for i = 1:size(didv,1)
    %clims = [min(didv(:)),max(didv(:))];
    clims = [-0.1E-8,1E-8];
    imagesc(flip(permute(squeeze(didv(i,:,:)),[2,1]),1),clims);
    colorbar;
    title(['V = ',num2str(Vred(i)),'V'], 'FontSize',16);
    axis image
%    colorsmap(cm_magma);
    %set(gcf, 'Colormap',gray) % the default one is cm_magma
      F = getframe(gcf);
    if nargin > 2, writeVideo(v, F), end
end

if nargin > 2, close(v), end

    


end

