function [avg_out, STD_out, comment] = avgXYstackedmasks(data, masks)
    % averaging data in x and y for the area determined by each layer of the 
    % set of stacked masks (eg. output from directional mask)
    %   The function takes data(x,y) or data(x,y,V) and applies each layer (L) 
    %   of the stack of masks to the data. It returns the average (avg_out) and 
    %   standard deviation (std_out) for each point. The output has the format: 
    %   XX_out(V,L), where each column corresponds to one layer. 
     
    % arguments
    %   data            2D data(x,y) like topo or 3D data(x,y,V) like dIdV
    %   masks           3D mask(x,y,L) of matching size in (x,y) and arbitrary length L 
    
    % returns 
    %   avg_out         array(V,L) of xy averaged values.   
    %   STD_out         standard veviation corresponding to avg_out
    %   comment         for logging the function call
    
    %   Rysa April 2025, Edited M. Altthaler 07/2025
    
    arguments
        data    {mustBeNumeric}
        masks   {mustBeNumericOrLogical}
    end
    
    %catch expeption if [] is parsed as mask:
    if isempty(masks)
        error('Need to provide mask!')
    end

    if ndims(masks) ~= 3
        error('Function requires a stacked mask(x,y,L)!')
    end

    if ndims(data) ~= 3 && ndims(data) ~= 2 
        error('Data needs to be of format: data(x,y) or data(x,y,V)!')
    end
    
    %LOG comment of function call
    comment = sprintf("avgMaskFast(didv:%s x %s x %s, mask:%s x %s x %s)|", ...
        mat2str(size(data,1)), mat2str(size(data,2)), mat2str(size(data,3)), mat2str(size(masks, 1)), ...
        mat2str(size(masks, 2)), mat2str(size(masks, 3)));
    
    %mask: 0 -> NaN
    masks = double(masks); %need to convert to double to allow NaN
    masks(masks==0) = NaN;
    
    % preallocate memory for output variables
    avg_out = zeros(size(data, 3),size(masks, 3)); 
    STD_out = zeros(size(data, 3),size(masks, 3));
    
    % iteratively assign avg and STD for each layer L 
    for i = 1:size(masks, 3)
        mask_expanded = repmat(masks(:,:,i), [1 1 size(data, 3)]);
        masked_data = data.*mask_expanded; % apply the mask
        avg = squeeze(mean(masked_data, [1 2], "omitnan")); 
        avg_out(:, i) = avg; % stack
        STD = squeeze(std(masked_data,0,[1,2],"omitnan"));
        STD_out(:, i) = STD; % stack
    end
end