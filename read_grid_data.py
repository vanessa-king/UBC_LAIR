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

full_3ds = nap.read.Grid(sys.argv[1])
# full_3ds contains everything in the .3ds file
# sys.argv[1] takes the first command-line input. Used to get input from MATLAB


#print("This file has the following channels: ",full_3ds.header['channels'])

#print("This file has the following parameters: ", full_3ds.header['experimental_parameters'])

#-------Treatment of grid data-------

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

gridArrays = [x, y, V, I]

