function userResponse = promptYesNo()
    % Define the dialog options
    opts.Interpreter = 'none';  % Set interpreter to 'none' to avoid special character interpretation
    opts.Default = 'No';        % Set 'No' as the default option
    
    % Display the dialog box
    answer = questdlg('Mask artefacts?', ...  % Prompt message
                      'Proceed Confirmation', ...     % Dialog box title
                      'Yes', 'No', opts);             % Options with default set to 'No'
    
    % Interpret the user's response
    switch answer
        case 'Yes'
            userResponse = true;
        case 'No'
            userResponse = false;
        otherwise
            userResponse = false;  % Default to 'No' if dialog is closed or no option is selected
    end
end