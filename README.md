# UBC_LAIR

README: maintrunk.m
~~~~~~~~~~Overview~~~~~~~~~~

You will need MATLAB R2024a to run this script.

The maintrunk.m script is the central workflow for processing, analyzing, and visualizing STM data. It is structured into modular blocks, each responsible for a specific task such as loading data, processing, selecting regions, or generating plots. These blocks are logged automatically to ensure reproducibility.

This script is designed to work with STM topographic and spectroscopy data, handling tasks like:
Loading topographic and spectral data
Processing I-V and dI/dV curves
Selecting specific regions using masks
Visualizing and exporting results

~~~~~~~~~~How It Works~~~~~~~~~~
The script follows a block-based structure, where each block is identified by a unique 5-character identifier (ABXXZ):

A = Category (L = Load, P = Process, V = Visualize, S = Select, etc.)
B = Subcategory (D = Data, F = Flatten, M = Mask, etc.)
XX = Running number (01, 02, ...)
Z = Variation letter (A, B, C...)
Example Block Identifier: VS02A
V → Visualization
S → Spectrum
02 → Next related block
A → First variant
Each block logs its execution, including function calls, parameters, and saved outputs.

~~~~~~~~~~Required MATLAB Toolboxes~~~~~~~~~~

To run mainTrunk.m and its associated functions, the following MATLAB toolboxes are required:

- Signal Processing Toolbox (for filtering, smoothing, and derivative calculations)
- Image Processing Toolbox (for masks, visualizations, and topography analysis)
- Curve Fitting Toolbox (for data smoothing and normalization)
- Optimization Toolbox (for drift correction and plane subtraction)

Note: The script may work without some toolboxes, but certain features (e.g., smoothing or masking) will be limited.

~~~~~~~~~~Getting Started~~~~~~~~~~

1. Set Up the Log File
When you run maintrunk.m, the first step initializes a log file where all executed blocks are recorded. You will be prompted to select a folder and name the log file.

2. Load Data
Use the Load-Data-01-A (LD01A) block to select and load datasets. Supported formats include grid (.3ds), topography (.sxm), and workspace files (.mat).

3. Process Data
Various Processing (P) blocks handle data transformations:
PD01A → Computes dI/dV
PD01B → Computes normalized dI/dV (dI/dV / I)
PA01A → Smooths I-V curves
PC02A → Corrects drift in grids

4. Select Regions (Optional)
Selection blocks (SMxxA, SLxxA) let you apply masks:
SM01A → Create directional masks
SM02A → Apply circular masks
SM03A → Define rectangular masks
SM05A → Create polygonal masks

5.Visualize and Save Figures
Use Visualization (V) blocks to generate plots:
VS01A → Plot average I-V / dI/dV
VS02A → Click on a grid to extract spectra
VT01A → Display a dI/dV slice at a given voltage
VG01A → Visualize an entire dI/dV grid stack
Each visualization block allows users to interactively select regions or define pre-selected coordinates.

6. Save the Workspace (Optional)
Before closing MATLAB, save your workspace using SW01A to store all loaded data and logs.

~~~~~~~~~~Miscellanea~~~~~~~~~~

Adjusting Parameters
Each block contains preset parameters that users can modify, including but not limited to: imageV (voltage to display); n (number of points to select); and offset (for shifting spectra).

Logging and Debugging
Every block logs its execution in the specified log file.
If an error occurs, check the log file for details.

Notes
If you experience missing lines in the MATLAB editor, try disabling code folding or copying the script into a plain text editor to confirm all lines are present or selecting all, deleting all, and re-pasting all..
Ensure that dependencies (logUsedBlocks, uniqueNamePrompt, etc.) are available in your MATLAB path.