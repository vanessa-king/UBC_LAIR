#Requirements:
# - Python 3.8 or 3.9 : so that Matlab can run this file on your behalf
# - Git

#If first time using, do the following:
#For Mac: In a new terminal window (zsh):
#1. type "git clone https://github.com/underchemist/nanonispy.git"
#2. change your folder using "cd currentfolder/nanonispy" where 'currentfolder' is your current folder path
#3. type "python setup.py install"
#For windows on Git Bash:
#1. type "git clone https://github.com/underchemist/nanonispy.git"
#2. change your folder using "cd currentfolder/nanonispy" where 'currentfolder' is your current folder path
#3. type "python setup.py install"

#Description:
#A python script (not a function) that reads a Nanonis 3ds gridmap file using the nanonispy library.
#Provides the same unit conversions of x, y data as gridLoadData() for consistency.
#Parameters:
# full_3ds : everything within a 3ds file


import sys
import numpy as np
import nanonispy as nap


#-------Treatment of topo data-------

full_sxm = nap.read.Scan(sys.argv[2])
# full_sxm contains everything in the .sxm file
# sys.argv[2] takes the second command-line input. Used to get input from MATLAB

# creating x_img and y_img. Note the values are in nm and relative
[x_range, y_range] = full_sxm.header['scan_range']
x_range_nm = x_range*1e9 # converting range from m to nm
y_range_nm = y_range*1e9 # converting range from m to nm

[x_resolution, y_resolution] = full_sxm.header['scan_pixels']
x_img = np.linspace(0.0,x_range_nm, num=x_resolution)
y_img = np.linspace(0.0,y_range_nm, num=y_resolution)

# grabbing the center position of the sxm image 
[x_position_img, y_position_img] = full_sxm.header['scan_offset']

# making z_img. requires user input for whether to take forward or backward scan.
topo_direction = sys.argv[3]
if topo_direction != 'forward' and topo_direction != 'backward':
	print("Invalid topo direction. Choose either 'forward' or 'backward'.")
z_img = full_sxm.signals['Z'][topo_direction]
z_img = z_img*1e9 #Not a unit conversion, but necessary for transfer into MATLAB due to memory issues.


#-------Treatment of grid data-------

full_3ds = nap.read.Grid(sys.argv[1])
# full_3ds contains everything in the .3ds file
# sys.argv[1] takes the first command-line input. Used to get input from MATLAB

#print("This file has the following channels: ",full_3ds.header['channels'])

#print("This file has the following parameters: ", full_3ds.header['experimental_parameters'])

#X(m) experimental parameter, shape (num_x, num_y)
x = full_3ds.signals['params'][:, :, 2]
#Convert from m to nm
x = x*1e9 

#Y(m) experimental parameter, shape (num_x, num_y)
y = full_3ds.signals['params'][:, :, 3]
#Convert from m to nm
y = y*1e9

#V values of grid map, shape (num_V)
V = full_3ds.signals['sweep_signal']

#Current (A) fwd, shape (num_x, num_y, num_V)
I = full_3ds.signals[full_3ds.header['channels'][0]]
I = I*1e9 #Not a unit conversion, but necessary for transfer into MATLAB due to memory issues.

gridArrays = [x, y, V, I, x_img, y_img, z_img, x_position_img, y_position_img]
