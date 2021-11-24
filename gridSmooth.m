function [smooth_iv] = gridSmooth(iv,time)
%GRIDSMOOTH Applies moving-average smoothin on didv data vs. time.
%   iv = grid of iv data (3d matrix). Size n x length(time) x
%   length(time)
%   time = independent variable axis to plot didv against

smooth_iv = zeros(size(iv));
[~, second_dim, third_dim] = size(iv);
for i = 1:second_dim
    for j = 1:third_dim
        smooth_iv(:,i,j) = smooth(time, iv(:,i, j));
    end
end

end

