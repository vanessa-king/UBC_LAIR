function [data_slice, imN, V_actual] = dataSlice2D(data,n,V_reduced,imageV)
%Slice a 2D xy layer from a 3D grid by slice number or voltage 
%   The function expects 2D or 3D data and arguments to select the 2D slice 
%   of the grid. These are the slice number n (*and V_reduced*) OR  the 
%   voltage axis V_reduced and the target voltage imageV. If n is given the
%   function picks the n-th slice of data (*and returns the corresponding
%   voltage V_actual*). If imageV is given the function finds the closest
%   voltage in V_reduced and returns the matching 2D slice. For 2D data no 
%   changes are applied. imN and V_actual are assigne if applicable.  

% returns: 
%   data_slice  2D slice of data
%   imN         index of the selected slice 
%   V_actual    actual voltage of the selected slice (*opt*) 

arguments
    data        {mustBeNumeric}
    n           {mustBePositive} =[]     %slice number 
    V_reduced   {mustBeNumeric}  =[]     %voltage axis
    imageV      {mustBeNumeric}  =[]     %target voltage
end

%argument checks for matching inputs
if ~isempty(n) && n>size(data,3)
    %n out of bounds
    error('n exceeds 3rd dimension of the data.');
end
if ~isempty(V_reduced) && length(V_reduced) ~= size(data,3)
    % V_reduced must match 3rd dim of data
    error('V_reduced does not match the dimensions of the 3D data.');
end
if ~isempty(imageV) && (imageV < min(V_reduced) || imageV > max(V_reduced))
    %imageV out of bounds
    error('imageV exceeds the limits of V_reduced.');
end

%making the slice
dimData = ndims(data);
if dimData == 3
    % 3D -> 2D conversion 
    % using n (and V_reduced) OR V_reduced and imageV are used. 
    if ~isempty(n) && ~isempty(V_reduced) && ~isempty(imageV) 
        % all 3 inputs given -> overdefined input
        [~,imNtest] = min(abs(V_reduced-imageV));
        if imNtest == n
            %Warining - but runs as both inputs select the same slice
            disp('Overdefined inputs for 3D data. Use either n (and V_reduced) OR V_reduced and imageV! \n Function will execute since both inputs select the same 2D slice.')
        else
            %Error - Stops execution as slice selection is abiguous
            error('Overdefined inputs for 3D data. Use either n (and V_reduced) OR V_reduced and imageV! \n Remove argument(s) to ensure an unambiguous selection of the 2D slice.');
        end
    end
    if ~isempty(n)
        % use n to pick slice 
        imN = n;
        % assign the actual voltage of the picked data if possible
        if ~isempty(V_reduced)
            V_actual = V_reduced(n);
        else
            V_actual = [];
        end
    elseif ~isempty(V_reduced) && ~isempty(imageV) 
        % use V_reduced and imageV to pick slice 
        [~,imN] = min(abs(V_reduced-imageV)); % Extract the index of the voltage closest to imageV
        V_actual = V_reduced(imN);
    else
        %incomplete input parameters
        error('For 3D data, either n (and V_reduced) OR both V_reduced and imageV are required inputs.');
    end
    % Select the energy slice for processing
    data_slice = data(:,:,imN); 
elseif dimData == 2
    % 2D data parsed to begin with
    data_slice = data;  % Use data directly for 2D case
    imN = 1;
    if ~isempty(V_reduced)
        V_actual = V_reduced(1);
    else
        V_actual = [];
    end
else
    % data is not 3D or 2D 
    error('Data must be either 2D or 3D.');   
end 
end