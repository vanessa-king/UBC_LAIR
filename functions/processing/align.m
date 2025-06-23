function [topoBeforeCorrected, Before_registration, comment] = align(topoBefore,topoAfter, scaling)
%Aligns two images
%   Align a before and after topography image and returns the
%   transformation and the corrected after topographic image. 
%   Allows for translation and rotation (a.k.a. a 'rigid' transformation)
%   Input: 
%   - topoBefore: [x,y] 2D array of values from the before topo (ie: z)
%   - topoAfter: [x,y] 2D array of values from the after topo (ie: z)
%   - scaling: boolean - if the transformation can allow for isotropic
%   scaling. This should be informed by the relative real space dimensions
%   of the two images
%   
%   Output:
%   - topoBeforeCorrected: [x,y] the before topo in the spatial reference 
%       frame of the after topo
%   - Before_registration: struct containing information on the
%       registration
%   Created by Vanessa April 2025

arguments
    topoBefore  {mustBeNumeric}     % 2D data
    topoAfter   {mustBeNumeric}     % 2D data
    scaling     {mustBeNumeric}     % boolean
end

% comment
comment = sprintf("topoPaneSub( topoBefore: %s x %s, topoAfter: %s x %s, scaling= %s)|", mat2str(size(topoBefore,1)),mat2str(size(topoBefore,2)), mat2str(size(topoAfter,1)),mat2str(size(topoAfter,2)), num2str(scaling));

figure;
subplot(1,2,1)
imshowpair(topoBefore,topoAfter);
axis image; axis xy;
title('Before and After Topo');

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

% Gradient correlation
if scaling==1 %Allow for isotropic scaling in addition to trranslation and rotation
    tform = imregcorr(topoBefore, beforeRefObj, topoAfter, afterRefObj,'Method','gradcorr','transformtype','similarity');
else %Only allow translation and rotation
    tform = imregcorr(topoBefore, beforeRefObj, topoAfter, afterRefObj,'Method','gradcorr','transformtype','rigid');
end
Before_registration.Transformation = tform;
topoBeforeCorrected = imwarp(topoBefore, beforeRefObj, tform, 'OutputView', afterRefObj, 'SmoothEdges', false);
% Store spatial referencing object
Before_registration.SpatialRefObj = afterRefObj;

subplot(1,2,2)
imshowpair(topoBeforeCorrected, topoAfter);
axis image; axis xy;
title('Corrected Before Topo and After Topo');

end