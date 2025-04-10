function [imgOut, comment] = twoImagesApplyFunction(img1,img2,type,mask1,mask2,n1,V_ax1,V_target1,n2,V_ax2,V_target2)
%Applies function of <type> to img1 and img2
%   Applies a function selected by type to img1 and img2. For
%   non-commutative operations, e.g. division: img1/img2. Accepts 2D images
%   or 3D-data paired with n, V_ax, V_target indicatign the xy slice. 
%   Additionally a mask can be applied to each image.  
%   Available functions:
%       add, subtract, multiply, divide

% M. Altthaler 04/2024

arguments
    img1        %first image 
    img2        %second image
    type        {mustBeText}        %function to be applied 
    mask1       =[]     %[optional] mask to be applied to image 1
    mask2       =[]     %[optional] mask to be applied to image 2
    n1          =[]     %[optional for 3D data] 1st imgage n  
    V_ax1       =[]     %[optional for 3D data] 1st imgage voltage axis 
    V_target1   =[]     %[optional for 3D data] 1st imgage target voltage
    n2          =[]     %[optional for 3D data] 2st imgage n 
    V_ax2       =[]     %[optional for 3D data] 2st imgage voltage axis 
    V_target2   =[]     %[optional for 3D data] 2st imgage target voltage 
end

%ensure 2D images
[img1, imN1, V_actual1] = dataSlice2D(img1,n1,V_ax1,V_target1);
[img2, imN2, V_actual2] = dataSlice2D(img2,n2,V_ax2,V_target2);
%apply mask if available
if ~isempty(mask1) 
    if size(img1,1)==size(mask1,1) && size(img1,2)==size(mask1,2)
        img1 = img1.*mask1;
    else
        error("mask1 incompatible with img1")
    end
end
if ~isempty(mask2) 
    if size(img2,1)==size(mask2,1) && size(img2,2)==size(mask2,2)
        img2 = img2.*mask2;
    else
        error("mask2 incompatible with img2")
    end
end
%ensure matching images and apply function
if size(img1,1)==size(img2,1) && size(img1,2)==size(img2,2)
    comment = sprintf("twoImagesApplyFunction(img1(imN1=%s,V_actual1=%s),img2(imN2=%s,V_actual2=%s), type=%s,  n1=%s,V_ax1=%s,V_target1=%s,n2=%s,V_ax2=%s,V_target2=%s)", mat2str(imN1), mat2str(V_actual1),mat2str(imN2), mat2str(V_actual2),type,mat2str(n1),mat2str(V_ax1),mat2str(V_target1),mat2str(n2),mat2str(V_ax2),mat2str(V_target2));
    %apply function based on type
    switch  type
        case 'add'
            imgOut = img1+img2;
        case 'subtract'
            imgOut = img1-img2;
        case 'multiply'
            imgOut = img1.*img2;
        case 'divide'
            imgOut = img1./img2;
        otherwise
            error("No defined function for type: %s", type)
    end
end
end

