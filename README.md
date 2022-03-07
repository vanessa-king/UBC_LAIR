# UBC_LAIR

Collection of data reading and data analysis codes from all UBC LAIR STMs

Sample function commenting format:

% Description
% what does the function do 
% Parameters
%%  Input parameters: name(type)
%%  Output parameters: name(type)
~~~~~~~~~~~function~~~~~~~~~~~~~



Parameter pool:

I : measured current as a function of voltage (3D array)
V : bias voltages
number_bias_layer : number of bias layers in a grid
V_reduced : reduced bias voltage
didv : 3D matrix with calculated dI/dV data
imageV : voltage at which to display image
n : number of point spectra to plot (from gridClickForSpectrum.m)
OR
n : number of points to sample (from topoPlaneSub.m)
offset : vertical offset for each point spectra
xysmooth : the standard deviation of a Gaussian for smoothing xy points (0 is no smoothing)
vsmooth : the standard deviation of a Gaussian for smoothing the voltage sweep points (0 is no smoothing)
grid : output from gridLoadData, grid map (1x1 structure)
norm_didv : 3D matrix with normalized dI/dV data
I_correction : current as a function of voltage corrected to 0 V.
C : normalization parameter
smooth : True/False for whether to smooth or not
mask : selected area, defined in the function ‘gridMaskPoint’
I_threshold : median I(V) value of slice
bright_indices : indices of I(V) values above I_threshold
dark_indices : indices of I(V) values below or equal to I_threshold
bias : voltage bias slice to threshold
nbins : number of bins
boundary_x : x values output from pixelatedContour
boundary_y : y values output from pixelatedContour
color_scale_resolution : number of evenly spaced colour points
clims : data value limits to be shown as a colour in a heat map.
folder : folder name
stamp_project : ?
img_number : number in name of image
grid_number : number in name of grid
average_forward_and_backward : True/False whether to average the forward and backward scan
Num_in_mask : number of points you are average over in the mask
radius : radius of mask in pixels
v : a VideoWriter object to write a new motion JPEG AVI file
Biases : specific bias values to plot
plotname : the plot names of the output plots for each value in Biases
plot : True/False for whether to plot or not
topo : topography 3D matrix
image : structure, output from topoLoadData.m
