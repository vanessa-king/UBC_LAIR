    %---Creates slices through the (r,V) space of a spectroscopy grid, where r
%---is an arbitrary pathway of connected linear segments in the (x,y) plane

%----INPUTS----
%--M: A matrix of data, with dimensions nV*nx*ny
%--x,y: Spatial axis vectors of the topography image
%--V: Vector of biases
%--im: The topography image
%--n: Number of nodes on the desired path

%----OUTPUTS----
%--slices: A structure containing a slice for each line segment, as well as
%----------a matrix with all slices together
%--xstruct: A structure containing the position vectors for the partial and 
%-----------full slices, as well as a vector with the corresponding corner
%-----------positions

function [slices,xstruct] = gridCreateConnectedSlices(M,x,y,V,im,n)

Nr = size(im,1)/size(M,2);
Nc = size(im,2)/size(M,3);
nbrrows = floor(sqrt(n-1));
totallength = 0;
totaldist = 0;
sxy = 0;
sv = 0;

%--Plot the topography image
TheImage = figure;
imagesc(im);axis image;colormap('gray');hold on

V = V(1:size(M,1));

%--Smooth the data
if sxy
    flt = fspecial('gaussian',ceil(sxy*5),sxy);
    for k = 1:size(M,1)
        M(k,:,:) = imfilter(squeeze(M(k,:,:)),flt,'replicate');
    end
end

if sv
    for k = 1:size(M,2)
        for l = 1:size(M,3)
            M(:,k,l) = Gauss1d(M(:,k,l),sv);
        end
    end
end

%--Defining the first point
disp('Please specify starting point')
p = round(ginput(1));
plot(p(1),p(2),'r.','MarkerSize',15)

%--Loop for subsequent points
for k = 1:n-1
    disp(['Please specify point number ',num2str(k+1)])
    pold = p;
    p = round(ginput(1)); %Asks for click input for point k+1
    plot(p(1),p(2),'r.','MarkerSize',15)
    px = [round(pold(1)/Nc) round(p(1)/Nc)];
    py = [round(pold(2)/Nr) round(p(2)/Nr)];
    tempprof = improfile(squeeze(M(1,:,:)),px,py); %Measures first profile to know length
    tempslice = NaN(length(tempprof),size(M,3)); %Defines dimensions of the slice
    
    %--Loop that measures profiles and adds to slice
    for l = 1:size(M,1)
        tempgridimg = squeeze(M(l,:,:)); %Picks a constant-bias-slice of the data
        tempprof = improfile(tempgridimg,px,py); %Measures the profile
        tempslice(:,l) = tempprof; %Adds the profile to the (V,r) slice
    end
    
    slices.(['Slice',num2str(k)]) = tempslice'; %Adds the slice to the slice structure

    %--Plots a line in the topography image
    if pold(1) < p(1)
        plot(pold(1):p(1),([pold(1):p(1)]-pold(1))*(p(2)-pold(2))/(p(1)-pold(1))+pold(2),'r','LineWidth',2)
    else
        plot(p(1):pold(1),([p(1):pold(1)]-pold(1))*(p(2)-pold(2))/(p(1)-pold(1))+pold(2),'r','LineWidth',2)
    end
    
    %--Define spatial coordinate vector for the slice
    dist = sqrt((y(p(2))-y(pold(2))).^2+(x(p(1))-x(pold(1))).^2);
    xstruct.(['xvec',num2str(k)]) = linspace(0,dist,length(tempprof));
    
    %--Count length and number of elements to later create full spatial
    %coordinate vector
    totallength = totallength + length(tempprof);
    totaldist = totaldist + dist;
end

%--This section adds the slices and coordinate vectors into one large slice
%--and one long coordinate vector
AllSlices = NaN(size(M,1),totallength);

startx = 0;
xind = NaN(1,n-1);
FullX = zeros(1,totallength);

for k = 1:n-1
    AllSlices(:,startx+1:startx+length(xstruct.(['xvec',num2str(k)]))) = slices.(['Slice',num2str(k)]);
    FullX(startx+1:startx+length(xstruct.(['xvec',num2str(k)]))) = max(FullX) + xstruct.(['xvec',num2str(k)]);
    startx = startx + length(xstruct.(['xvec',num2str(k)]));
    xind(k) = startx;
end 

%--Add the data into the output structures
slices.AllSlices = AllSlices;
xstruct.FullX = FullX;

for k = 1:n-2
    xstruct.xpoint(k) = xstruct.FullX(xind(k));
end

%--Plot the single slices in a subplot figure
if n > 2
    figure;
    for k = 1:n-1
        subplot(nbrrows,ceil((n-1)/nbrrows),k);
        imagesc(xstruct.(['xvec',num2str(k)]),V,slices.(['Slice',num2str(k)]));
        set(gca,'Ydir','Normal');
        xlabel('Distance /nm')
        ylabel('Energy /eV')
    end
end

%--Plot the single large slice in a separate figure
figure;
imagesc(xstruct.FullX,V,slices.AllSlices);
set(gca,'Ydir','Normal');
xlabel('Distance /nm')
ylabel('Energy /eV')
hold on

%--Add red dots to mark the corners of the selected path
if n > 2
    plot(xstruct.xpoint,0.95*max(V),'r.','MarkerSize',18)
end