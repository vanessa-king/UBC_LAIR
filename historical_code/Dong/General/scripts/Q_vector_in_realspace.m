% vector standard [row,col,height]
mean_max=[round(mean(row_max)),round(mean(col_max)),0];
q_vector_pixel = mean_max-[round(size(I1,1)/2),round(size(I1,2)/2),0]; 
c_axis = [-1,0,0]; % this could also be a-axis since we cant differentiate them in our QPI.

%Compute angle between q_vector_pixel and c_axis. 

angle = atan2(norm(cross(q_vector_pixel,c_axis)),dot(q_vector_pixel,c_axis));

%Norm of q_vector in real space.
a=6.4045;
b=11.30870;
c=6.3646;

pixel_size= (2*pi/c)/round(size(I1,2)/2);

real_space_norm_q_vector= 2*pi/(norm(q_vector_pixel)*pixel_size);