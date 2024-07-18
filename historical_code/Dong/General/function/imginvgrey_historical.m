function [I_inv] = imginvgrey(img)

%   Load the image

I = imread(img);
I = im2gray(I);
I_inv = uint8(255) - I;

end