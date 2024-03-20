function [mask,comment] = MaskSparseGrid(dataDimSize,stepSizeX,stepSizeY,numX,numY)
%mask a data set with a sparse grid of every 'stepSize' datapoint
%   2D data sets are masked with every 1 + n x stepSizeXY's point 
%   being 1 up to a limit of numXY. 
%Arguments
%   dataDimSize     dimensions of the data [xMax,yMax], e.g. size(data)
%   stepSizeX       step size in x direction, e.g. for 3: x -> 1,4,7,...  
%   stepSizeY       step size in y direction, e.g. for 3: y -> 1,4,7,...  
%   numX            max number in x, e.g. for 7: x -> 1,4,7
%   numY            max number in y, e.g. for 9: x -> 1,4,7

% M. Altthaler, March 2024

arguments 
    dataDimSize     {mustBeNumeric}
    stepSizeX       {mustBeNumeric, mustBePositive}=1
    stepSizeY       {mustBeNumeric, mustBePositive}=stepSizeX
    numX            {mustBeNumeric, mustBePositive}=dataDimSize(1)
    numY            {mustBeNumeric, mustBePositive}=dataDimSize(2)
end

% comment for logging
comment = sprintf("[Mask] = MaskSparseGrid(dataDimSize = [%d %d], stepSizeX = %d, stepSizeY = %d, numX = %d, numY = %d);|",dataDimSize(1),dataDimSize(2),stepSizeX,stepSizeY,numX,numY);

%making the 2D mask
N = numel(dataDimSize);
if N == 2
    %initalize 2D mask
    mask = zeros(dataDimSize);
    %coordinate grid up to data limits or max values numXYZ
    [X,Y] = meshgrid(1:dataDimSize(1),1:dataDimSize(2));
    %set 1's for XYcoords of appropriate step size
    X = mod((X+stepSizeX-1),stepSizeX); %X layers of 1's in the mask are 0 
    Y = mod((Y+stepSizeY-1),stepSizeY); %Y layers of 1's in the mask are 0
    dsc = (X==0 & Y==0); % superposition of XY
    clear X Y
    mask(dsc==1)=1;
    %max number numXY
    if numX < dataDimSize(1)
        mask(numX+1:dataDimSize(1),:,:)=0;
    end
    if numY < dataDimSize(2)
        mask(:,numY+1:dataDimSize(2),:)=0;
    end
else
    %wrong dim
    mask = [];
    disp("Data size parsed is not 2D.")
    return
end

end