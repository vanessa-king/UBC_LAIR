function [dIdV_masked, QPI_masked] = masking(dIdV,midV,V)

% Function takes in a 3D dIdV matrix (x,y,V)
% Also takes voltage vector, and user specified voltage to make mask at
% Outputs dIdV matrix with Gaussian smooth at all specified defect centres
% Also outputs FT QPI map of masked dIdV

%Defines uniform colour map
m = 1000;
cm_magma = magma(m);

%% Set dIdV to average 0

% Remove dIdV offset
for i = 1:size(dIdV,3)
    dIdV(:,:,i) = dIdV(:,:,i) - mean(mean(dIdV(:,:,i)));
end

%%

% Find index closest to user specified voltage
[c, index] = min(abs(V - midV(:)));

% set colour scale limits
clims = ([min(min(dIdV(:,:,index))) 0.1*max(max(dIdV(:,:,index)))]);


i = 1;
clear x
clear y
sigma = 10;
imagesc(dIdV(:,:,index),clims) % show dIdV at specified voltage
colormap(cm_magma)
pbaspect([1 1 1])

hold on
% Until user ends process by typing 'n' apply Gaussian mask at pointer
% location. Continue by typing 'y'. Creates two vectors with x and y index
% of gaussian masks
while 1
    [x(i), y(i)] = ginput(1);
    h = drawpoint('Position',[x(i) y(i)]);
    resp = input('Do you wish to mask another point? y/n \n','s');
    i = i + 1;
    fprintf(strcat('point',num2str(i),'\n')) % Outputs defect number
    if strcmpi(resp,'n')
        % user has typed in N or n so break out of the while loop
        break;
    end
end
hold off

B = zeros(size(dIdV,1),size(dIdV,2),length(x)); % Create masking matrix
dIdV_masked = dIdV(:,:,:); % Create output dIdV (set to all 0 for now)

fprintf('Creating mask \n')

% Creates a Gaussian mask at each user specified point from before
for k = 1:length(x)
    for i = 1:size(dIdV,1)
        for j = 1:size(dIdV,2)
            B(i,j,k) = 1 - exp(-(j-round(x(k)))^2/(2*sigma^2) - (i-round(y(k)))^2/(2*sigma^2));
        end
    end
end

fprintf('Masking dIdV \n')

% Multiplies the dIdV by the mask, removing defect signatures
for k = 1:length(x)
    dIdV_masked(:,:,:) = dIdV_masked(:,:,:).*B(:,:,k);
end

%%
% Take FT of dIdV for QPI map
fprintf('Fourier transforming \n')
QPI_masked(:,:,:) = abs(fftshift(fft2(dIdV_masked(:,:,:) - mean(mean(dIdV_masked(:,:,:))))));

end
