#If first use, do the following in a new terminal window (currently written for zsh):
#1. type "git clone https://github.com/underchemist/nanonispy.git"
#2. change your folder using "cd currentfolder/nanonispy" where 'currentfolder' is your current folder path
#3. type "python setup.py install"


import sys
import numpy as np
import nanonispy as nap

grid = nap.read.Grid(sys.argv[1])
# grid contains everything in the .3ds file
# sys.argv[1] takes the first command-line input. Used to get input from MATLAB


#print("This file has the following channels: ",grid.header['channels'])

#print("This file has the following parameters: ",grid.header['experimental_parameters'])

#-------Treatment of grid data-------

#X(m) experimental parameter, shape (num_x, num_y)
x = grid.signals['params'][:, :, 2]
#Convert from m to nm
x = x*1e9

#Y(m) experimental parameter, shape (num_x, num_y)
y = grid.signals['params'][:, :, 3]
#Convert from m to nm
y = y*1e9

#V values of grid map, shape (num_V)
V = grid.signals['sweep_signal']

#Current (A) fwd, shape (num_x, num_y, num_V)
I = grid.signals[grid.header['channels'][0]]
I = I*1e9 #Not a unit conversion, but necessary for transfer into MATLAB due to memory issues.

gridArrays = [x, y, V, I]

