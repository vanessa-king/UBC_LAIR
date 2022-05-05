# UBC_LAIR

Collection of data reading and data analysis codes from all UBC LAIR STMs

Sample function commenting format:

% Description

% what does the function do

% Parameters

%%  Input parameters: name(type)

%%  Output parameters: name(type)

function [output] = functionName(input)

~~~~~~~~~~~function~~~~~~~~~~~~~



Parameter pool and directory:
avg_I : mean of I data [gridAvg.m]
I : measured current as a function of voltage (3D array) [gridAvg.m, gridGetIVThreshold.m, gridPlotSlices.m]
V : bias voltages [gridAvg.m, gridGetIVThreshold.m, gridPlotSlices.m]
number_bias_layer : number of bias layers in a grid [gridAvg.m]
V_reduced : reduced bias voltage [gridClickForSpectrum.m, gridCorrectionNorm.m, gridMaskPoint.m, gridMovie.m]
didv : 3D matrix with calculated dI/dV data [gridAvgMask.m, gridClickForSpectrum.m, gridCorrec tionNorm.m, gridMaskPoint.m, gridMovie.m]
didv_avg : mean of didv data [gridAvgMask.m]
imageV : voltage at which to display image [gridClickForSpectrum.m, gridMaskPoint.m]
n : number of point spectra to plot [gridClickForSpectrum.m]
OR
n : number of points to sample [topoPlaneSub.m]
offset : vertical offset for each point spectra [gridClickForSpectrum.m]
xysmooth : the standard deviation of a Gaussian for smoothing xy points (0 is no smoothing) [gridClickForSpectrum.m]
vsmooth : the standard deviation of a Gaussian for smoothing the voltage sweep points (0 is no smoothing) [gridClickForSpectrum.m]
grid : grid map (structure) containing x_img, y_img, z_img, x, y, V, and I data [gridLoadDataUpward.m, gridClickForSpectrum.m, gridCorrectionNorm.m, pythonDataToGrid.m]
norm_didv : 3D matrix with normalized dI/dV data [gridCorrectionNorm.m]
I_correction : current as a function of voltage corrected to 0 V. [gridCorrectionNorm.m]
C : normalization parameter [gridCorrectionNorm.m]
smooth : True/False for whether to smooth or not [gridCorrectionNorm.m]
normalize : True/False for whether to normalize or not [gridCorrectionNorm.m]
mask : boolean matrix of a selected area [gridMaskPoint.m, gridAvgMask.m, gridMaskPoint.m]
I_threshold : median I(V) value of slice [gridGetIVThreshold.m]
bright_indices : indices of I(V) values above I_threshold [gridGetIVThreshold.m]
dark_indices : indices of I(V) values below or equal to I_threshold [gridGetIVThreshold.m]
bias : voltage bias slice to threshold [gridGetIVThreshold.m]
nbins : number of bins [gridGetIVThreshold.m]
boundary_x : x values output from pixelatedContour [pixelatedContour.m, gridGetIVThreshold.m]
boundary_y : y values output from pixelatedContour [pixelatedContour.m, gridGetIVThreshold.m]
color_scale_resolution : number of evenly spaced colour points [gridMaskPoint.m, gridMovie.m, gridPlotSlices.m]
clims : data value limits to be shown as a colour in a heat map. [gridMaskPoint.m, gridMovie.m, gridPlotSlices.m]
folder : folder name [gridLoadDataUpward.m]
stamp_project : project number [gridLoadDataUpward.m]
img_number : number in name of image [gridLoadDataUpward.m]
grid_number : number in name of grid [gridLoadDataUpward.m]
average_forward_and_backward : True/False whether to average the forward and backward scan [gridLoadDataUpward.m]
Num_in_mask : number of points you want to average over in the mask [gridMaskPoint.m]
radius : radius of mask in pixels [gridMaskPoint.m]
v : a VideoWriter object to write a new motion JPEG AVI file [gridMovie.m]
Biases : specific bias values to plot [gridPlotSlices.m]
plotname : the plot names of the output plots for each value in Biases [gridPlotSlices.m]
plot : True/False for whether to plot or not [topoPlaneSub.m]
topo : topography 3D matrix [topoPlaneSub.m]
image : structure, contains topo data. [topoLoadData.m, topoPlaneSub.m]
didv_masked : masked version of didv [gridAvgMask.m]
contour : boolean matrix corresponding to bright_indices and dark_indices [gridGetIVThreshold.m, pixelatedContour.m]
fileName : stringo of full path and file name, including extension. [pythonDataToGrid.m]
full_3ds : everything within a 3ds file, as read by the nanonispy library [read_grid_data.py]
gridArrays : 4D array containing the x, y, V, I data of a grid [read_grid_data.py]
