function [scaling_ratio] = lengthscaling(I1,I2,length_ratio)
%This function create a scaling ratio that makes 1D object in img1 to match
%real length in img2.
%   Vector_in_img1(unit pixel) * scaling ratio = Vector_in_img2(unit pixel)

arguments
    I1  
    I2
    length_ratio     % length_img1/length_img2
end 

%   Create scaling ratio 
scaling_ratio = length_ratio*(size(I2,1)/size(I1,1));

end