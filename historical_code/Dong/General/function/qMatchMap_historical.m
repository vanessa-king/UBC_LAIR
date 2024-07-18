function [mappedT, mappedQ, lineCoords] = qMatchMap(img,drow,dcol,thresholdVal)
%highlight pixels that match a q-vector 
%   Highlight start (=2) and end (=1) pixels in the mappedQ image, that 
%   match the q-vector described by [drow, dcol]. mappedT returns all 
%   pixels above the treshold. 

%arguments
%   img             2D image of bandstructure
%   drow            q-vectro component
%   dcol            q-vectro component
%   thresholdVal    min. value for a pixel to be considered valid as a
%                   start or edn point

%returns
%   mappedT         map of all pixels above threshold
%   mappedQ         map of valid start and end pixels matching the q-vector
%   lineCoords      coordinates to plot matching q-vectors, format:
%                   [row , col, row_off, col_off, row_jump, col_jump],


arguments
    img             
    drow            {mustBeNumeric,mustBeNonnegative}
    dcol            {mustBeNumeric,mustBeNonnegative}
    thresholdVal    {mustBeNumeric,mustBePositive}
end

%apply threshold to identify 'start pixels'
mappedT = img >= thresholdVal;

%list of coordinates for start pixels
[row,col] = find(mappedT);
%calculate end pixels based of [drow, dcol], includes folding
row_off = mod(row+drow,size(img,1));
row_off(row_off==0)=size(img,1);
col_off = mod(col+dcol,size(img,2));
col_off(col_off==0)=size(img,2);

%calculate the image 'jumps' for umklapp q-vectors
row_jump = fix((row+drow)./size(img,1));
col_jump = fix((col+dcol)./size(img,2));

%initialize output map & coord list
mappedQ = zeros(size(img));
lineCoords = NaN(size(row, 1),6);
%set values for start and end pixels (Note: serial assignment to same pixel
%is overwritten by last assignment)
for n=1:length(row_off)
    if img(row_off(n),col_off(n)) <= thresholdVal
        mappedQ(row_off(n),col_off(n)) = 1;
        mappedQ(row(n),col(n)) = 2;
        %set line coords: [row , col, row_off, col_off, row_jump, col_jump]
        lineCoords(n,:) = [row(n), col(n), row_off(n), col_off(n),row_jump(n),col_jump(n)];
    end
end
lineCoords = reshape(lineCoords(~isnan(lineCoords)),[],6);

end