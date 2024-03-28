function [mask,comment] = MaskSparse3DGrid(dataDimSize,stepSizeX,stepSizeY,stepSizeZ,numX,numY,numZ)
%mask a data set with a sparse grid of every 'stepSize' datapoint
%   3D data sets are masked with every 1 + n x stepSize's point 
%   being 1 up to a limit of numXY. 
%Arguments
%   dataDimSize     dimensions of the data [xMax,yMax, zMax], e.g. size(data)
%   stepSizeX       step size in x direction, e.g. for 3: x -> 1,4,7,...  
%   stepSizeY       step size in y direction, e.g. for 3: y -> 1,4,7,...  
%   stepSizeZ       step size in z direction, e.g. for 2: z -> 1,3,5,...  
%   numX            max number in x, e.g. for 7: x -> 1,4,7
%   numY            max number in y, e.g. for 9: y -> 1,4,7
%   numZ            max number in z, e.g. for 6: z -> 1,3,5

% M. Altthaler, March 2024 

arguments 
    dataDimSize     {mustBeNumeric}
    stepSizeX       {mustBeNumeric, mustBePositive}=2
    stepSizeY       {mustBeNumeric, mustBePositive}=stepSizeX
    stepSizeZ       {mustBeNumeric, mustBePositive}=stepSizeX
    numX            {mustBeNumeric, mustBePositive}=dataDimSize(1)
    numY            {mustBeNumeric, mustBePositive}=dataDimSize(2)
    numZ            {mustBeNumeric, mustBePositive}=dataDimSize(2)
end

% comment for logging
comment = sprintf("[Mask] = MaskSparseGrid(dataDimSize = [%d %d %d], stepSizeX = %d, stepSizeY = %d, stepSizeZ = %d, numX = %d, numY = %d, numZ = %d);|",dataDimSize(1),dataDimSize(2),dataDimSize(3),stepSizeX,stepSizeY,stepSizeZ,numX,numY,numZ);

%making the 2D mask
N = numel(dataDimSize);
if N == 3
    %initalize 3D mask
    mask = zeros(dataDimSize);
    %coordinate grid up to data limits or max values numXYZ
    [X,Y,Z] = meshgrid(1:dataDimSize(1),1:dataDimSize(2),1:dataDimSize(3));
    %set 1's for XYZ coords of appropriate step size
    X = mod((X+stepSizeX-1),stepSizeX); %X layers of 1's in the mask are 0 
    Y = mod((Y+stepSizeY-1),stepSizeY); %Y layers of 1's in the mask are 0
    Z = mod((Z+stepSizeZ-1),stepSizeZ); %Z layers of 1's in the mask are 0
    dsc = (X==0 & Y==0 & Z==0); % superposition of XYZ
    clear X Y Z 
    mask(dsc==1)=1;
    %max number numXYZ
    if numX < dataDimSize(1)
        mask(numX+1:dataDimSize(1),:,:)=0;
    end
    if numY < dataDimSize(2)
        mask(:,numY+1:dataDimSize(2),:)=0;
    end
    if numZ < dataDimSize(3)
        mask(:,:,numZ+1:dataDimSize(3))=0;
    end
else
    %non 3D
    mask = [];
    disp("Data size parsed is not 3D.")
    return
end
mask = logical(mask); %set datatype
end