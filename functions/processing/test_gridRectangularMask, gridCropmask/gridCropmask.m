function [Cropped_data] = gridCropmask(data,mask)
arguments
    data    
    mask      
end

[row,col]= find(mask);
x_start=min(row);
x_end= max(row);
y_start= min(col);
y_end= max(col);

Cropped_data = data(x_start:x_end,y_start:y_end);

