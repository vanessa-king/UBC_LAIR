function [selectedDataset, selectedVariable] = selectDatasetVariable(data, titleString, descriptionString)
    % This function creates a GUI to select a dataset and a variable within
    % the nested structure `data`. It returns the selected dataset and variable
    % field names.
    % Inputs
    %   data:               struct containing datasets and variables
    %   titleString:        string displayed as a large label at the top of the GUI
    %   descriptionString:  a description text explaining the choice to be made
    % Returns
    %   selectedDataset     <dataset>
    %   selectedVariable    <variable> 
    %                       for data.(<dataset>).(<variable>) inputs of any function 

    arguments
        data
        titleString         {mustBeText}
        descriptionString   {mustBeText}
    end

    
    % Create the UI figure
    fig = uifigure('Name', 'Select Dataset and Variable', 'Position', [100 100 400 450]);

    % Initialize UserData to store selections
    fig.UserData.selectedDataset = '';
    fig.UserData.selectedVariable = '';

    % Create a large label for the title
    uilabel(fig, 'Position', [50, 410, 300, 30], 'Text', titleString, 'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

    % Create a label for the description
    uilabel(fig, 'Position', [20, 320, 360, 80], 'Text', descriptionString, 'FontSize', 12, 'HorizontalAlignment', 'center', 'WordWrap', 'on');

    % Create a label for the dataset listbox
    uilabel(fig, 'Position', [20, 270, 150, 20], 'Text', 'Dataset', 'FontSize', 12, 'HorizontalAlignment', 'center');

    % Create a listbox for datasets
    datasetNames = fieldnames(data);  % Get dataset names from the struct
    datasetList = uilistbox(fig, ...
        'Position', [20, 70, 150, 200], ...
        'Items', datasetNames, ...
        'ValueChangedFcn', @(src, event) updateVariableList(src, data));

    % Create a label for the variable listbox
    uilabel(fig, 'Position', [220, 270, 150, 20], 'Text', 'Variable', 'FontSize', 12, 'HorizontalAlignment', 'center');

    % Create a second listbox for variables
    variableList = uilistbox(fig, ...
        'Position', [220, 70, 150, 200], ...
        'Items', {}, ...
        'Enable', 'off');  % Initially disabled until a dataset is selected

    % Create a button for confirming selection
    confirmButton = uibutton(fig, 'push', ...
        'Text', 'Confirm Selection', ...
        'Position', [135, 30, 120, 30], ...
        'Enable', 'off', ...  % Initially disabled until a dataset and variable are selected
        'ButtonPushedFcn', @(src, event) confirmSelection(fig, datasetList, variableList));

    % Preselect the first dataset and trigger the value change
    datasetList.Value = datasetNames{1};  % Preselect the first dataset
    updateVariableList(datasetList, data);  % Trigger variable list update for the first dataset

    % Block MATLAB execution until user closes the GUI
    uiwait(fig);

    % Output the selected dataset and variable
    selectedDataset = fig.UserData.selectedDataset;
    selectedVariable = fig.UserData.selectedVariable;
    
    % Close the figure
    close(fig);
end

%%% helper functions unique to this function 

function updateVariableList(datasetList, data)
    % This function updates the variable list based on the selected dataset
    selectedDataset = datasetList.Value;
    variables = fieldnames(data.(selectedDataset));

    % Find the variable listbox handle in the figure
    variableList = findobj(datasetList.Parent, 'Type', 'uilistbox', 'Position', [220, 70, 150, 200]);

    % Update the variable list
    variableList.Items = variables;
    variableList.Enable = 'on';  % Enable the list now that a dataset is selected

    % Preselect the first variable if available
    if ~isempty(variables)
        variableList.Value = variables{1};  % Preselect the first variable
        confirmButton = findobj(datasetList.Parent, 'Type', 'uibutton');
        confirmButton.Enable = 'on';  % Enable the confirm button
    else
        confirmButton.Enable = 'off';  % Disable the confirm button if no variables
    end
end

function confirmSelection(fig, datasetList, variableList)
    % This function retrieves the selected dataset and variable and stores them in fig.UserData
    selectedDataset = datasetList.Value;
    selectedVariable = variableList.Value;

    % Store selected values in the figure's UserData to return later
    fig.UserData.selectedDataset = selectedDataset;
    fig.UserData.selectedVariable = selectedVariable;

    % Resume the UI and allow the main function to continue
    uiresume(fig);
end
