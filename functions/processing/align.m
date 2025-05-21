function [transform, topoAfterCorrected] = align(topoBefore,topoAfter)
%Aligns two images
%   Align a before and after topography image and returns the
%   transformation and the corrected after topographic image. Allows for
%   translation, rotation, anisotropic scaling, and shearing.
%   Input: 
%   - topoBefore: [x,y] 2D array of values from the before topo (ie: z)
%   - topoAfter: [x,y] 2D array of values from the after topo (ie: z)
%   
%   Output:
%   - transform: affinetform2d, the calculated affine geometric transformation 
%   - topoAfterCorrected: [x,y] 2D array of values !check if this is true,
%   or if the dimensions change
%   Created by Vanessa April 2025

figure;
hold on;
title('Before and after topo');
imshowpair(topoBefore,topoAfter);
axis image;
axis xy;
hold off;

registrationEstimator(topoAfter,topoBefore)

topoAfterCorrected = imwarp(topoAfter, transform);

figure;
hold on;
title('Before topo and corrected after topo');
imshowpair(topoBefore,topoAfterCorrected);
axis image;
axis xy;
hold off;


end