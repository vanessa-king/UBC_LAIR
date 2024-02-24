function [topo, comment] = topoLoadData(fld,stamp_project,img_nbr)

arguments
    fld             {mustBeFolder}
    stamp_project   {mustBeText}
    img_nbr         {mustBeText}
end

%TOPOLOADDATA Load topography files from Omicron (z_flat).
%   fld - folder where flat files are stored (string)
%   stamp_project - name of the project (string)
%   img_nbr - the image number (string)
%
%   Outputs a structure with topography data:
%     x_img - the x axis of image
%     y_img - the y axis of image
%     z_img - the actual topographic heights

%output format for comment: "<function>(<VAR1>=<VAR1_value>,<VAR2>=<VAR2_value>,<VAR3>,...,)|"  
%Never plot data (e.g. the whole gird) in the comment, only plot the values
%('=<VARn_value>') of variables that decide/affect how the function
%processes data (e.g. order of fit, ...) 
%Note convert all <VARn_value> to strings; 
comment = sprintf("topoLoadData(fld=%s, stamp_project=%s, img_nbr=%s)|", fld, stamp_project, img_nbr);

%regular function processing:

z_file = [stamp_project img_nbr '.Z_flat'];

addpath(fld);

fz = flat_parse(z_file);
mz = flat2matrix(fz);

rmpath(fld);

xraw = 1e9*mz{2};
yraw = 1e9*mz{3};

zraw = mz{1};

if find(abs(diff(sign(diff(xraw))))) % Check if image is scanned forwards and backwards
                                     % only take the forward
    topo.x_img = xraw(1:length(xraw)/2);
    ztmp = zraw(1:length(xraw)/2,:);
else
    topo.x_img = xraw;
    ztmp = zraw;
end

if find(abs(diff(sign(diff(yraw))))) % Check if swept up and down
                                     % only take the up
    topo.y_img = yraw(1:length(yraw)/2);
    topo.z_img = ztmp(:,1:length(yraw)/2);
else
    topo.y_img = yraw;
    topo.z_img = ztmp;
end

end

