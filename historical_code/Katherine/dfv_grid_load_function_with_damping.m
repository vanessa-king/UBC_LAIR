%dfv_grid_load_function.m

function[dfV,IV,damping,df_topo,I_topo,V,x,y,x_topo,y_topo]=dfv_grid_load_function_with_damping(grid_folder,I_topo_file,damping_file,df_topo_file,dfV_file,IV_file,up_dn,fwd_bkwd,nV_smooth,nxy_smooth,C);

% if up_down = 0, then the grid was up only 
% if up_down = 1, the grid was up and down and you are choosing the up
% scan
% if up_down = 2, the grid was up and down and you are choosing the down
% scan
% 
% 
% %  
% grid_folder='flat20161019';
%   IV_file='20161019-141200_PTCDA_NaCl_ag111--143_1.I(V)_flat';
%   dfV_file='20161019-141200_PTCDA_NaCl_ag111--143_1.Df(V)_flat';
%   df_topo_file='20161019-141200_PTCDA_NaCl_ag111--65_1.Df_flat';
% I_topo_file='20161019-141200_PTCDA_NaCl_ag111--65_1.I_flat';
% 
% damping_file='20161019-141200_PTCDA_NaCl_ag111--143_1.Damping(V)_flat';
% 
% 
% nV_smooth=3;
% nxy_smooth=3;
% C=1e-11;
% 
% up_dn=1; 
% fwd_bkwd=0;
 %%
addpath(grid_folder)

directory=grid_folder;
%loading files from matrix flat to matlab structures
f_dfV=flat_parse(dfV_file);
m_dfV=flat2matrix(f_dfV);
f_IV=flat_parse(IV_file);
m_IV=flat2matrix(f_IV);
f_I_topo=flat_parse(I_topo_file);
m_I_topo=flat2matrix(f_I_topo);
f_df_topo=flat_parse(df_topo_file);
m_df_topo=flat2matrix(f_df_topo);
f_damping=flat_parse(damping_file);
m_damping=flat2matrix(f_damping);

%df topography extrapolation
f_df_topo=flat_parse(df_topo_file);
m_df_topo=flat2matrix(f_df_topo);

x_topo=m_df_topo{1,2};
y_topo=m_df_topo{1,3};
df_topo_extract=m_df_topo{1,1};

if fwd_bkwd == 1
    topo_size_x=length(x_topo)./2;
    x_topo=x_topo(1:topo_size_x);
    df_topo=df_topo_extract(1:topo_size_x,:);
elseif fwd_bkwd == 0 
    topo_size_x=length(x_topo);
    df_topo=df_topo_extract;
end

if up_dn == 1
    topo_size_y=length(y_topo)./2;
    y_topo=y_topo(1:topo_size_y);
    df_topo=df_topo(:,1:topo_size_y);
elseif up_dn == 2
    topo_size_y=length(y_topo)./2;
    y_topo=y_topo((topo_size_y+1):end);
    df_topo=df_topo(:,(topo_size_y+1):end);
elseif up_dn == 0
    topo_size_y=length(y_topo);
end

%I topography extrapolation
f_I_topo=flat_parse(I_topo_file);
m_I_topo=flat2matrix(f_I_topo);

I_topo_extract=m_I_topo{1,1};

if fwd_bkwd == 1
    I_topo=I_topo_extract(1:topo_size_x,:);
elseif fwd_bkwd == 0 
    I_topo=I_topo_extract;
end

if up_dn == 1
    I_topo=I_topo(:,1:topo_size_y);
elseif up_dn == 2
    I_topo=I_topo(:,(topo_size_y+1):end);
end

figname='I and df Topography';
figure ('Name', figname);
subplot(1,2,1);
imagesc(x_topo, y_topo, df_topo');
title('df Topography');
axis xy;
axis image;
ylabel('y [m]');
xlabel('x [m]');
colorbar;
subplot(1,2,2);
imagesc(x_topo, y_topo, I_topo');
title('I topography');
axis xy;
axis image;
ylabel('y [m]');
xlabel('x [m]');
colorbar;

%dfV extrapolation
x=m_dfV{1,3};
y=m_dfV{1,4};
V=m_dfV{1,2}(1:(length(m_dfV{1,2})/2));
dfV_extract=m_dfV{1,1};

grid_size_x=length(x);
if up_dn == 1
    grid_size_y=length(y)/2;
    y=y(1:grid_size_y);
    dfV_raw=dfV_extract(:,:,1:grid_size_y);
elseif up_dn == 2
    grid_size_y=length(y)/2;
    y=y(1:grid_size_y);
    dfV_raw=dfV_extract(:,:,(grid_size_y+1):end);
elseif up_dn == 0
    grid_size_y=length(y);
    dfV_raw=dfV_extract;
end

V_length=length(V);
dfV.dfV_fwd=dfV_raw(1:V_length,:,:);
dfV.dfV_bkwd=dfV_raw((V_length+1):end,:,:);

for i=1:length(x)
       for j=1:length(y)
dfV.dfV_bkwd(:,i,j)=flipud(dfV.dfV_bkwd(:,i,j));
dfV.dfV_ave(:,i,j)=(dfV.dfV_bkwd(:,i,j)+dfV.dfV_fwd(:,i,j))./2;


%         for k=1:length(V)
%            
% temp=dfV.dfV_fwd(k,i,j);
% temp(isnan(temp))=0;
% dfV.dfV_fwd(k,i,j)=temp;
% 
%             
%         end
       end
end

dfV.dfV_fwd(isnan(dfV.dfV_fwd))=0;
dfV.dfV_ave(isnan(dfV.dfV_ave))=0;
dfV.dfV_bkwd(isnan(dfV.dfV_bkwd))=0;

dfV.dfV_smooth=smooth3(dfV.dfV_ave, 'box', [nV_smooth,nxy_smooth,nxy_smooth]);
%%
%damping extraction


%dfV extrapolation

damping_extract=m_damping{1,1};

grid_size_x=length(x);
if up_dn == 1
    damping_raw=damping_extract(:,:,1:grid_size_y);
elseif up_dn == 2
    damping_raw=damping_extract(:,:,(grid_size_y+1):end);
elseif up_dn == 0
    damping_raw=damping_extract;
end

damping.damping_fwd=damping_raw(1:V_length,:,:);
damping.damping_bkwd=damping_raw((V_length+1):end,:,:);

for i=1:length(x)
       for j=1:length(y)
damping.damping_bkwd(:,i,j)=flipud(damping.damping_bkwd(:,i,j));
damping.damping_ave(:,i,j)=(damping.damping_bkwd(:,i,j)+damping.damping_fwd(:,i,j))./2;
       end
end

damping.damping_smooth=smooth3(damping.damping_ave, 'box', [nV_smooth,nxy_smooth,nxy_smooth]);

%%
%IV extrapolation
IV_extract=m_IV{1,1};

if up_dn == 1
    IV_raw=IV_extract(:,:,1:grid_size_y);
elseif up_dn == 2
    IV_raw=IV_extract(:,:,(grid_size_y+1):end);
elseif up_dn == 0
    IV_raw=IV_extract;
end

IV.IV_fwd=IV_raw(1:V_length,:,:);
IV.IV_bkwd=IV_raw((V_length+1):end,:,:);
for i=1:length(x)
       for j=1:length(y)
IV.IV_bkwd(:,i,j)=flipud(IV.IV_bkwd(:,i,j));
 IV.IV_ave(:,i,j)=(IV.IV_fwd(:,i,j)+IV.IV_bkwd(:,i,j))./2;
       end
end

%subtracting off set and normalizing

a=zeros(1,length(V));
for i=1:length(V);
if V(i)<0;
a(i)=0;
else
a(i)=1;
end
end 

b=find(a);
cross_V_number=length(V)-length(b);


intercept=zeros(length(x),length(y));
IV.IV_corrected=zeros(length(V),length(x),length(y));
I_grid=smooth3(IV.IV_ave,'box',[nV_smooth,nxy_smooth,nxy_smooth]);
for i=1:length(x)
   for j=1:length(y)
       
       intercept(i,j)=I_grid(cross_V_number,i,j)-V(cross_V_number).*(I_grid(cross_V_number+1,i,j)-I_grid(cross_V_number,i,j))./(V(cross_V_number+1)-V(cross_V_number));
           %for incomplete grids, to remove NaN
           l=isnan(intercept(i,j));
            if l==1
               intercept(i,j)=0;
           end
       for k=1:length(V)
           
      IV.IV_corrected(k,i,j)=(I_grid(k,i,j)-intercept(i,j));


       end
       
        IV.IV_smooth(:,i,j)=smooth(IV.IV_ave(:,i,j),nV_smooth);   
        IV.IV_corrected_smooth_extreme(:,i,j)=smooth(IV.IV_corrected(:,i,j),25);

   end
end

IV.IV_corrected_smooth=smooth3(IV.IV_corrected, 'box', [nV_smooth,nxy_smooth,nxy_smooth]);

for i=1:length(x)
   for j=1:length(y)
           IV.dIdV(:,i,j)=diff(IV.IV_corrected_smooth(:,i,j))./diff(V);          
           IV.dIdV_smooth(:,i,j)=smooth(IV.dIdV(:,i,j),nV_smooth);           
           IV.norm_dIdV(:,i,j)=IV.dIdV_smooth(:,i,j)./(IV.IV_corrected_smooth_extreme(1:length(IV.dIdV_smooth(:,i,j)),i,j)./V(1:length(IV.dIdV_smooth(:,i,j))));
           IV.norm_dIdV_smooth(:,i,j)=smooth(IV.norm_dIdV(:,i,j),nV_smooth); 
           
            IV.norm_devision_offset_factor(:,i,j) = sqrt((IV.IV_corrected_smooth_extreme(:,i,j)./V(1:length(IV.IV_corrected_smooth(:,i,j)))).^2 + C^2);
            IV.norm_dIdV_offset(:,i,j)=IV.dIdV_smooth(:,i,j)./IV.norm_devision_offset_factor(1:length(IV.dIdV_smooth(:,i,j)),i,j);
            IV.norm_dIdV_offset_smooth(:,i,j)=smooth(IV.norm_dIdV_offset(:,i,j),nV_smooth); 
   end
end

end