function [dataCorrected, topoCorrected, xCorrected, yCorrected, Before_registration, comment] = driftCorrection(data, before, after)
%Correct for drift over time in a grid map.
%   Calculates the drift from before and after topography images and skews
%   the grid to compensate. You can rotate by angle theta (deg) if you
%   so choose. Assumes drift speed is linear
%   Input: 
%   - data: [x,y,V] 3D array of values (ie: I or z)
%   - before: [x,y] 2D array of values from the before topo (ie: z)
%   - after: [x,y] 2D array of values from the after topo (ie: z)
%   
%   Output:
%   - xCorrected: [x,y] 2D array of x values corresponding to the
%   transformed topo
%   - yCorrected: [x,y] 2D array of x values corresponding to the
%   transformed topo
%   - dataCorrected: [x,y,V] 3D array of values transformed to remove drift (ie: I or z)
%
%   Note that skew results in a larger grid. Extra elements are left as 0.
%   The x,y scale for the topography and grid are extended linearly to
%   accomodate.
%   Edited by Vanessa April 2025

arguments
    data          
    before
    after      
end

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Never plot data (e.g. the whole grid) in the comment, only plot the values
%('=<VARn_value>') of variables that decide/affect how the function
%processes data (e.g. order of fit, ...) 
%Note convert all <VARn_value> to strings; 
formatSpec = "driftCorrection(data: %s, before: %s, after: %s, theta=%.3g degrees)|";
comment = sprintf(formatSpec,mat2str(size(data)), mat2str(size(before)), mat2str(size(after)), theta);

%regular function processing:

[topoCorrected, Before_registration] = align(before, after);

transformedImage = topoCorrected;
transform = Before_registration.Transform;
 
%temp = imwarp(squeeze(data(1,:,:)),transform); %Hmm, check what grid(1,:,:) is supposed to be
%iv = zeros(length(grid.V),size(temp,1), size(temp,2));
%for i = 1:length(grid.V)
%    iv(i,:,:) = imwarp(squeeze(grid.iv(i,:,:)),transform);
%end

% redefine x and y axis, distances should be preserved
%x_img = linspace(0,mean(diff(grid.x))*size(z_img,1),size(z_img,1));
%y_img = linspace(0,mean(diff(grid.y))*size(z_img,2),size(z_img,2));
%x = linspace(0,mean(diff(grid.x))*size(iv,2),size(iv,2));
%y = linspace(0,mean(diff(grid.y))*size(iv,3),size(iv,3));

% assign values
%dataCorrected = z_img;
%xCorrected = x;
%yCorrected = y;


% plot preview
%figure; 
%hold on;
%imagesc(xCorrected, yCorrected, zCorrected',[min(z(:)),max(z(:))]);
%title('Z topography (drift corrected)');
%xlabel('x / nm');ylabel('y / nm');
%axis image;
%axis xy;
%hold off;

end
