function flat_preview
% FLAT_PREVIEW allows to select multiple flat files in a file select box 
% and creates simple plots of the data using flat_plot.
%
%See also FLAT_TOOLBOX, FLAT_PLOT, FLAT_PARSE, FLAT2MATRIX

    [File,Path]=uigetfile('*flat', 'Get Matrix-Data','MultiSelect','on');
    if ~iscell(File) File={File}; end %if only one file then put string into cell array to ease later handling
    for i=1:length(File) %for each file
        figure(i) %create a figure
        flat_plot(flat_parse([Path File{i}])) %load and plot it
        title(File{i}); %put filename as title
    end