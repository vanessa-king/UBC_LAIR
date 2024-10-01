function [selectedDatasets, selectedVariables] = selectMultipleDatasetVariable(data, titleStrings, descriptionStrings)
    % Number of titles to handle
    numTitles = length(titleStrings);

    % Create the UI figure
    fig = uifigure('Name', 'Select Multiple Datasets and Variables', 'Position', [100 100 600 500]);

    % Initialize UserData to store selections and status
    fig.UserData.selectedDatasets = cell(1, numTitles);
    fig.UserData.selectedVariables = cell(1, numTitles);
    fig.UserData.isAssigned = false(1, numTitles);  % Track assignments

    % Create the status label (green or red) for assigned/unassigned
    statusLabel = uilabel(fig, 'Position', [20, 420, 150, 20], ...
        'Text', 'Unassigned', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    statusLabel.FontColor = [1 0 0];  % Initially red for unassigned

    % Create a listbox for the titles (input/output variables)
    titleList = uilistbox(fig, ...
        'Position', [20, 160, 150, 250], ...
        'Items', titleStrings, ...
        'Value', titleStrings{1}, ...  % Preselect the first item
        'ValueChangedFcn', @(src, event) updateSelection(src, fig, descriptionStrings, data));

    % Create a label to display the corresponding description
    descriptionLabel = uilabel(fig, 'Position', [200, 350, 380, 40], ...
        'Text', descriptionStrings{1}, 'FontSize', 12, 'HorizontalAlignment', 'left', 'WordWrap', 'on');

    % Create a listbox for datasets
    datasetNames = fieldnames(data);  % Get dataset names from the struct
    datasetList = uilistbox(fig, ...
        'Position', [200, 160, 150, 100], ...
        'Items', datasetNames, ...
        'Value', datasetNames{1}, ...  % Preselect the first dataset
        'ValueChangedFcn', @(src, event) updateVariableList(src, data, fig));

    % Create a second listbox for variables
    variableList = uilistbox(fig, ...
        'Position', [380, 160, 100, 100], ...
        'Items', {}, ...
        'Enable', 'on');  % Initially enabled

    % Create a button for confirming the current dataset and variable selection
    selectButton = uibutton(fig, 'push', ...
        'Text', 'Assign Dataset & Variable', ...
        'Position', [200, 100, 280, 30], ...
        'ButtonPushedFcn', @(src, event) confirmSelection(fig, titleList, datasetList, variableList));

    % Create a button for finishing the entire process
    finishButton = uibutton(fig, 'push', ...
        'Text', 'End & Confirm All Selections', ...
        'Position', [200, 50, 280, 30], ...
        'ButtonPushedFcn', @(src, event) finishSelection(fig, titleStrings));

    % Initialize the selection for the first item in the title list
    updateSelection(titleList, fig, descriptionStrings, data);

    % Block MATLAB execution until the user closes the GUI
    uiwait(fig);

    % Output the selected datasets and variables
    selectedDatasets = fig.UserData.selectedDatasets;
    selectedVariables = fig.UserData.selectedVariables;

    % Close the figure
    close(fig);
end

function updateSelection(titleList, fig, descriptionStrings, data)
    % Get the current selected title index
    currentTitle = titleList.Value;
    titleIndex = find(strcmp(titleList.Items, currentTitle));

    % Update the description label based on the selected title
    descriptionLabel = findobj(fig, 'Type', 'uilabel', 'Position', [200, 350, 380, 40]);
    descriptionLabel.Text = descriptionStrings{titleIndex};

    % Update the assignment status label (green for assigned, red for unassigned)
    statusLabel = findobj(fig, 'Type', 'uilabel', 'Position', [20, 420, 150, 20]);
    if fig.UserData.isAssigned(titleIndex)
        statusLabel.Text = 'Assigned';
        statusLabel.FontColor = [0 0.5 0];  % Dark green for assigned
    else
        statusLabel.Text = 'Unassigned';
        statusLabel.FontColor = [1 0 0];  % Red for unassigned
    end

    % Get dataset list and variable list
    datasetList = findobj(fig, 'Type', 'uilistbox', 'Position', [200, 160, 150, 100]);
    variableList = findobj(fig, 'Type', 'uilistbox', 'Position', [380, 160, 100, 100]);

    % Reset dataset to the first dataset and update the variable list
    datasetNames = fieldnames(data);
    datasetList.Value = datasetNames{1};  % Reset to the first dataset
    updateVariableList(datasetList, data, fig);  % Update the variable list based on the first dataset
end

function updateVariableList(datasetList, data, fig)
    % Update the variable list based on the selected dataset
    selectedDataset = datasetList.Value;
    variables = fieldnames(data.(selectedDataset));

    % Find the variable listbox handle in the figure
    variableList = findobj(fig, 'Type', 'uilistbox', 'Position', [380, 160, 100, 100]);

    % Update the variable list
    variableList.Items = variables;

    % Preselect the first variable if available
    if ~isempty(variables)
        variableList.Value = variables{1};  % Preselect the first variable
    end
end

function confirmSelection(fig, titleList, datasetList, variableList)
    % Retrieve the selected dataset and variable
    selectedDataset = datasetList.Value;
    selectedVariable = variableList.Value;

    % Get the index of the current selected title
    currentTitle = titleList.Value;
    titleIndex = find(strcmp(titleList.Items, currentTitle));

    % Store the selected dataset and variable for the current title
    fig.UserData.selectedDatasets{titleIndex} = selectedDataset;
    fig.UserData.selectedVariables{titleIndex} = selectedVariable;
    fig.UserData.isAssigned(titleIndex) = true;  % Mark as assigned

    % Update the assignment status label
    statusLabel = findobj(fig, 'Type', 'uilabel', 'Position', [20, 420, 150, 20]);
    statusLabel.Text = 'Assigned';
    statusLabel.FontColor = [0 0.5 0];  % Dark green for assigned
end

function finishSelection(fig, titleStrings)
    % Check if all titles have been assigned datasets and variables
    if all(fig.UserData.isAssigned)
        % Display a summary of selected datasets and variables in a popup
        selectedDatasets = fig.UserData.selectedDatasets;
        selectedVariables = fig.UserData.selectedVariables;

        summaryText = sprintf('Summary of Selections:\n\n');
        for i = 1:length(titleStrings)
            summaryText = [summaryText, sprintf('%s: Dataset = %s, Variable = %s\n', ...
                titleStrings{i}, selectedDatasets{i}, selectedVariables{i})];
        end

        % Show the final popup with two buttons: Edit and Confirm
        dialog = uifigure('Position', [300, 300, 400, 250], 'Name', 'Confirm or Edit Selections');
        msgLabel = uilabel(dialog, 'Position', [20, 100, 360, 100], 'Text', summaryText, 'FontSize', 12, 'HorizontalAlignment', 'left', 'WordWrap', 'on');

        % Edit button to go back to the main GUI
        editButton = uibutton(dialog, 'push', ...
            'Text', 'Edit Selections', ...
            'Position', [50, 30, 120, 30], ...
            'ButtonPushedFcn', @(src, event) close(dialog));

        % Confirm button to finalize selections and exit the function
        confirmButton = uibutton(dialog, 'push', ...
            'Text', 'Confirm', ...
            'Position', [220, 30, 120, 30], ...
            'ButtonPushedFcn', @(src, event) confirmAndClose(fig, dialog));
    else
        uialert(fig, 'Please assign datasets and variables for all items.', 'Incomplete Selections');
    end
end

function confirmAndClose(fig, dialog)
    % Close the confirmation dialog and the main figure, ending the function
    close(dialog);
    uiresume(fig);
end
