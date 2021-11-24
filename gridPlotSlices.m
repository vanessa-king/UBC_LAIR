function [] = gridPlotSlices(IVdata,V,Biases,plotname)

% load colourmap
m = 1000; % 1000 evenly spaced colour points
cm_viridis = viridis(m); % Default matlibplot
cm_inferno = inferno(m);
cm_magma = magma(m);
cm_plasma = plasma(m);

IVdata = flip(permute(IVdata,[1 3 2]),2);

% sxy = 0;
% sv = 0;
% 
% if sxy
%     flt = fspecial('gaussian',ceil(sxy*5),sxy);
%     for k = 1:size(IVdata,1)
%         IVdata(k,:,:) = imfilter(squeeze(IVdata(k,:,:)),flt,'replicate');
%     end
% end
% 
% if sv
%     for k = 1:size(IVdata,2)
%         for l = 1:size(IVdata,3)
%             IVdata(:,k,l) = Gauss1d(IVdata(:,k,l),sv);
%         end
%     end
% end

N = length(Biases);
cols = ceil(sqrt(N))+1;
rows = ceil(N/cols);

NegRamp = V(length(V))-V(1) < 0;

%mi = 0;ma = max(max(max(IVdata(find(V < Biases(1),1):find(V < Biases(length(Biases)),1),:,:))));

figure('Name', plotname)
for k = 1:N
    subplot(rows,cols,k)
    if NegRamp
        temp_ind = find(V < Biases(k),1);
    else
        temp_ind = find(V > Biases(k),1);
    end
    clims = [0,3E-9];   
    %clims = [0,5];    %for 2V pheny state on coordinated molecules 
    %clims = [0,2.0];
    %55:85,70:95
    imagesc(squeeze(IVdata(temp_ind,:,:)),clims)
    colorbar
    colormap(cm_magma)
        %image(64/(ma-mi)*(squeeze(IVdata(temp_ind,:,:))-mi))
        axis image
        title([num2str(V(temp_ind)),' V'])
%         ma = 2*mean(mean(sqrt(squeeze(IVdata(k,:,:)).^2)));mi = -ma;
%         image(64*(squeeze(IVdata(temp_ind,:,:))-mi)/(ma-mi))
%         axis image
%         title([num2str(V(temp_ind)),' V'])
%         colormap(diffcolour);

end
