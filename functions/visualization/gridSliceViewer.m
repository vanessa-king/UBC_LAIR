function sliced_grid = gridSliceViewer(data, EnergyLayer, rangeType, colormapName)
% SLICEVIEWERDEC2 Processes and displays 3D dIdV data with selectable range type, colormap, and coordinate mapping
% Merged version of sliceViewer2 and d3gridDisplay by Jiabin Nov 2024
%
% Inputs:
%   data: Raw dIdV data - 3D matrix of scanning tunneling spectroscopy data
%   EnergyLayer: Number of layers - Integer specifying total layers
%   rangeType: Type of range for visualization ('global' or 'dynamic')
%   colormapName: Name of the colormap to use (default is 'invgray')
%
% Output:
%   sliced_grid: 4D matrix containing processed image slices

arguments
    data                (:,:,:) {mustBeNumeric}
    EnergyLayer         (1,1) {mustBeInteger, mustBePositive}
    rangeType           (1,:) char {mustBeMember(rangeType, {'global', 'dynamic'})}
    colormapName        (1,:) char = 'invgray'
end

% Default parameters
if isempty(colormapName)
    colormapName = 'invgray';
end

% Load specified colormap
try
    if strcmp(colormapName, 'invgray')
        load('InverseGray', 'invgray');
        map = invgray;
    else
        % Use MATLAB's built-in colormap
        map = colormap(colormapName);
    end
catch
    % Fallback to default inverse gray if colormap loading fails
    warning('Could not load specified colormap. Falling back to invgray.');
    load('InverseGray', 'invgray');
    map = invgray;
end

% Validate EnergyLayer against data size
if EnergyLayer > size(data, 3) + 1
    error('EnergyLayer cannot be larger than the number of layers in the input data plus one');
end

% Grid: output variable to be dispalyed by imshow3D
% Transpose and flip to match Cartesian coordinates
Grid = permute(data, [2 1 3]);  % Swap x and y dimensions
Grid = flip(Grid, 1);  % Flip vertically to match Cartesian orientation

% Initialize visualization
figure('Name', sprintf('3D Grid View - %s Range, %s Colormap', rangeType, colormapName));

% Determine global min and max values if global range is selected
if strcmp(rangeType, 'global')
    globalMin = min(Grid(:));
    globalMax = max(Grid(:));
end

% Pre-allocate the sliced grid array
sliced_grid = zeros(size(Grid,1), size(Grid,2), size(Grid,3), 3);

% Parameter for dynamic range contrast
nos = 8;

% Convert Grid to image format using the colormap
for k = 1:size(Grid, 3)
    if strcmp(rangeType, 'dynamic')
        MeddIdV = median(median(Grid(:,:,k)));
        Stdv = std(std(Grid(:,:,k)));
        range = [MeddIdV-nos*Stdv MeddIdV+nos*Stdv];
    else
        range = [globalMin globalMax];
    end
    sliced_grid(:,:,k,:) = mat2im(Grid(:,:,k), map, range);
end

% Display the 3D image stack
imshow3D(sliced_grid);
end


function im=mat2im(mat,cmap,limits)
    % mat2im - convert to rgb image
    %
    % function im=mat2im(mat,cmap,maxVal)
    %
    % Description: 
    % Uses vectorized code to convert matrix "mat" to an m-by-n-by-3
    % image matrix which can be handled by the Mathworks image-processing
    % functions. The the image is created using a specified color-map
    % and, optionally, a specified maximum value. Note that it discards
    % negative values!
    %
    % INPUTS
    % mat     - an m-by-n matrix  
    % cmap    - an m-by-3 color-map matrix. e.g. hot(100). If the colormap has 
    %           few rows (e.g. less than 20 or so) then the image will appear 
    %           contour-like.
    % limits  - by default the image is normalised to it's max and min values
    %           so as to use the full dynamic range of the
    %           colormap. Alternatively, it may be normalised to between
    %           limits(1) and limits(2). Nan values in limits are ignored. So
    %           to clip the max alone you would do, for example, [nan, 2]
    %          
    %
    % OUTPUTS
    % im - an m-by-n-by-3 image matrix  
    %
    %
    % Example 1 - combine multiple color maps on one figure 
    % clf, colormap jet, r=rand(40);
    % subplot(1,3,1),imagesc(r), axis equal off , title('jet')
    % subplot(1,3,2),imshow(mat2im(r,hot(100))) , title('hot')
    % subplot(1,3,3),imshow(mat2im(r,summer(100))), title('summer')
    % colormap winter %changes colormap in only the first panel
    %
    % Example 2 - clipping
    % p=peaks(128); J=jet(100);
    % subplot(2,2,1), imshow(mat2im(p,J)); title('Unclipped')
    % subplot(2,2,2), imshow(mat2im(p,J,[0,nan])); title('Remove pixels <0')
    % subplot(2,2,3), imshow(mat2im(p,J,[nan,0])); title('Remove pixels >0')
    % subplot(2,2,4), imshow(mat2im(p,J,[-1,3])); title('Plot narrow pixel range')
    %
    % Rob Campbell - April 2009
    %
    % See Also: ind2rgb, imadjust
    
    
    %Check input arguments
    error(nargchk(2,3,nargin));
    
    if ~isa(mat, 'double')
        mat = double(mat)+1;    % Switch to one based indexing
    end
    
    if ~isnumeric(cmap)
        error('cmap must be a colormap, such as jet(100)')
    end
    
    
    %Clip if desired
    L=length(cmap);
    if nargin==3 && length(limits)==1
        warning('limits should be vector of length of 2. Assuming a max value was specified.')
        limits=[nan,limits];
    end
    
    
    if nargin==3
        minVal=limits(1);
        if isnan(minVal), minVal=min(mat(:)); end    
        mat(mat<minVal)=minVal;
        
        maxVal=limits(2);
        if isnan(maxVal), maxVal=max(mat(:)); end
        mat(mat>maxVal)=maxVal;        
    else
    minVal=min(mat(:));
    maxVal=max(mat(:));
    end
    
    
    %Normalise 
    mat=mat-minVal;
    mat=(mat/(maxVal-minVal))*(L-1);
    mat=mat+1;
    
    
    %convert to indecies 
    mat=round(mat); 
    
    
    %Vectorised way of making the image matrix 
    im=reshape(cmap(mat(:),:),[size(mat),3]);
    
end