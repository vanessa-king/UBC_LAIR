function [topoBeforeCorrected, Before_registration] = align(topoBefore,topoAfter)
%Aligns two images
%   Align a before and after topography image and returns the
%   transformation and the corrected after topographic image. Allows for
%   translation, rotation, and isotropic scaling.
%   Input: 
%   - topoBefore: [x,y] 2D array of values from the before topo (ie: z)
%   - topoAfter: [x,y] 2D array of values from the after topo (ie: z)
%   
%   Output:

%   Created by Vanessa April 2025

figure;
imshowpair(topoBefore,topoAfter);
axis image;
axis xy;
title('Before and After Topo');
set(gca,'Position',[0 0 1 0.9])

%% Normalize after (fixed) image: code edited from RegistrationEstimator app
% Get linear indices to finite valued data
finiteIdx = isfinite(topoAfter(:));

% Replace NaN values with 0
topoAfter(isnan(topoAfter)) = 0;

% Replace Inf values with 1
topoAfter(topoAfter==Inf) = 1;

% Replace -Inf values with 0
topoAfter(topoAfter==-Inf) = 0;

% Normalize input data to range in [0,1].
topoAftermin = min(topoAfter(:));
topoAftermax = max(topoAfter(:));
if isequal(topoAftermax,topoAftermin)
    topoAfter = 0*topoAfter;
else
    topoAfter(finiteIdx) = (topoAfter(finiteIdx) - topoAftermin) ./ (topoAftermax - topoAftermin);
end

%% Normalize before (moving) image
% Get linear indices to finite valued data
finiteIdx = isfinite(topoBefore(:));

% Replace NaN values with 0
topoBefore(isnan(topoBefore)) = 0;

% Replace Inf values with 1
topoBefore(topoBefore==Inf) = 1;

% Replace -Inf values with 0
topoBefore(topoBefore==-Inf) = 0;

% Normalize input data to range in [0,1].
topoBeforemin = min(topoBefore(:));
topoBeforemax = max(topoBefore(:));
if isequal(topoBeforemax,topoBeforemin)
    topoBefore = 0*topoBefore;
else
    topoBefore(finiteIdx) = (topoBefore(finiteIdx) - topoBeforemin) ./ (topoBeforemax - topoBeforemin);
end

% Default spatial referencing objects
afterRefObj = imref2d(size(topoAfter));
beforeRefObj = imref2d(size(topoBefore));

% Phase correlation
tform = imregcorr(topoBefore, beforeRefObj, topoAfter, afterRefObj,'Method','gradcorr','transformtype','similarity');
Before_registration.Transformation = tform;
topoBeforeCorrected = imwarp(topoBefore, beforeRefObj, tform, 'OutputView', afterRefObj, 'SmoothEdges', true);
% Store spatial referencing object
Before_registration.SpatialRefObj = afterRefObj;

figure;
imshowpair(topoBeforeCorrected, topoAfter);
axis image;
axis xy;
title('Corrected Before Topo and After Topo');
set(gca,'Position',[0 0 1 0.9])

end