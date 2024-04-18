function [Max,row_max,col_max] = findlocalmax(I_inv)
%This function find the local maximum pixel within the circle that the user draw

%   Create a circular mask on the image based on the circle drawn by the user  

Mask = imgMaskdraw(I_inv); 
I_inv(~Mask) = 0;
Max = max(I_inv,[],"all");
[row_max,col_max] = find(I_inv==Max);

%   Plot the Max_index on the original image 
    %Here insertMarker has a reverse order of col and row. 
RGB = insertMarker(I_inv,[col_max(1) row_max(1)],"circle");
imshow(RGB)

end