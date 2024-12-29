close all;
clear all;
clc;
warning('off');
startuplocal();
%set(groot, 'Default', struct());
DBF_GUI();

function DBF_GUI()
    % Default values for the variables
    defaultValues.SNRTherm = 10;
    defaultValues.SIR = 100;
    defaultValues.M = 1;
    defaultValues.K = 1;
    defaultValues.B = 5;
    defaultValues.Angle = 0;
    defaultValues.BlockerAngle = 15;
    defaultValues.UserAngleSpacing = 22.5;
    defaultValues.QAMNumSymbols = 1000;
    defaultValues.QAMOrder = 16;

    % Default values for boolean variables
    defaultBooleans.addThermNoise = 1;
    defaultBooleans.ZFOn = 0;
    defaultBooleans.EnableBlocker = 0;
    defaultBooleans.SweepBlockerAngle = 0;
    defaultBooleans.SweepUserAngle = 0;
    

    logs.LogScaleX = 0;
    logs.LogScaleY = 0;
    logs.LogScaleZ = 0;

    % Starting position for GUI elements
    startX = 20;
    startY = 20;

    % Create the GUI
    hFig = figure('Name', 'Select Variables to Sweep', 'NumberTitle', 'off', 'Position', [100, 100, 950, 500]);

    % Outputs to Plot Dropdown
    outputOptions = {'BER', 'EVM', 'SNDR', 'ENOB', 'Minimum SIR', 'Array Gain'};
    uicontrol('Style', 'text', 'String', 'Plot Output: (Z-axis)', 'Position', [startX, startY + 400, 100, 20]);
    outputDropdown = uicontrol('Style', 'popupmenu', 'String', outputOptions, 'Position', [startX + 110, startY + 400, 100, 25], 'Tag', 'outputDropdown', 'Callback', @updateSweepInputs);
    % Get selected output to plot
    



    % Add "Fit data" checkbox to the right of the dropdown
    fitDataCheckbox = uicontrol('Style', 'checkbox', 'String', 'Fit data', 'Position', [startX + 220, startY + 400, 100, 25], 'Tag', 'fitDataCheckbox');


    % Plot button
    uicontrol('Style', 'pushbutton', 'String', 'Plot', 'Position', [startX + 350, startY + 10, 100, 30], 'Callback', @plotButtonCallback);


    % Log scale checkboxes 
    logsNames = fieldnames(logs);
    for i = 1:length(logsNames)
        uicontrol('Style', 'checkbox', 'String', logsNames{i}, 'Position', [startX, startY + 370-(i-1)*30, 140, 25], 'Tag', logsNames{i}, 'Value', logs.(logsNames{i}));
    end
    %%%%%%%%%%%%%%%%%%%%%%%
    % Sweepable Variables %
    %%%%%%%%%%%%%%%%%%%%%%%
    sweepVars = {'SNRTherm', 'SIR', 'M', 'K', 'B', 'Angle'};
    nVars = length(sweepVars);

    % Add "None" option to the list of variable names
    varNamesWithNone = ['None', sweepVars];

    % Dropdowns for selecting sweep variables
    uicontrol('Style', 'text', 'String', 'Sweep 1: (X-axis)', 'Position', [startX + 220, startY + 380, 100, 20]);
    sweepVar1Dropdown = uicontrol('Style', 'popupmenu', 'String', varNamesWithNone, 'Position', [startX + 330, startY + 380, 100, 25], 'Tag', 'sweepVar1', 'Callback', @updateSweepInputs);

    uicontrol('Style', 'text', 'String', 'Sweep 2: (Y-axis)', 'Position', [startX + 220, startY + 340, 100, 20]);
    sweepVar2Dropdown = uicontrol('Style', 'popupmenu', 'String', varNamesWithNone, 'Position', [startX + 330, startY + 340, 100, 25], 'Tag', 'sweepVar2', 'Callback', @updateSweepInputs);
    multCurves2Checkbox = uicontrol('Style', 'checkbox', 'String', 'Multiple Curves?', 'Position', [startX + 440, startY + 340, 120, 25], 'Tag', 'multCurves2');

    uicontrol('Style', 'text', 'String', 'Sweep 3:', 'Position', [startX + 220, startY + 300, 100, 20]);
    sweepVar3Dropdown = uicontrol('Style', 'popupmenu', 'String', varNamesWithNone, 'Position', [startX + 330, startY + 300, 100, 25], 'Tag', 'sweepVar3', 'Callback', @updateSweepInputs);
    multCurves3Checkbox = uicontrol('Style', 'checkbox', 'String', 'Multiple Curves?', 'Position', [startX + 440, startY + 300, 120, 25], 'Tag', 'multCurves3');

    % UI elements for inputting sweep ranges and variable values
    sweepInputs = struct();
    valueInputs = struct();

    % Generate GUI elements for sweepable variables
    for i = 1:nVars
        uicontrol('Style', 'text', 'String', sweepVars{i}, 'Position', [startX + 220, startY + 270-(i-1)*40, 80, 20]);

        % Sweep range inputs (start, end, step)
        sweepInputs.(sweepVars{i}).start = uicontrol('Style', 'edit', 'Position', [startX + 310, startY + 270-(i-1)*40, 60, 25], 'Tag', [sweepVars{i} '_start'], 'String', num2str(defaultValues.(sweepVars{i})), 'Visible', 'off');
        uicontrol('Style', 'text', 'String', 'to', 'Position', [startX + 375, startY + 270-(i-1)*40, 20, 20], 'Visible', 'off', 'Tag', [sweepVars{i} '_to']);
        sweepInputs.(sweepVars{i}).end = uicontrol('Style', 'edit', 'Position', [startX + 400, startY + 270-(i-1)*40, 60, 25], 'Tag', [sweepVars{i} '_end'], 'String', num2str(defaultValues.(sweepVars{i})), 'Visible', 'off');
        uicontrol('Style', 'text', 'String', 'Step', 'Position', [startX + 470, startY + 270-(i-1)*40, 40, 20], 'Visible', 'off', 'Tag', [sweepVars{i} '_stepLabel']);
        sweepInputs.(sweepVars{i}).step = uicontrol('Style', 'edit', 'Position', [startX + 515, startY + 270-(i-1)*40, 60, 25], 'Tag', [sweepVars{i} '_step'], 'String', '1', 'Visible', 'off');
        
        valueInputs.(sweepVars{i}) = uicontrol('Style', 'edit', 'Position', [startX + 635, startY + 270-(i-1)*40, 60, 25], 'Tag', [sweepVars{i} '_value'], 'String', num2str(defaultValues.(sweepVars{i})));

        %Special cases for certain sweep variables below:
        %Don't set a 'Value' input box next to 'Angle'. Instead, use
        %BlockerAngle and UserAngleSpacing as default angle values
        if strcmp(sweepVars{i}, 'Angle')
            % Nominal value input
            set(valueInputs.('Angle'), 'Visible', 'off');
        else
            uicontrol('Style', 'text', 'String', 'Value', 'Position', [startX + 590, startY + 270-(i-1)*40, 40, 20]);
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Generate GUI elements for non-sweepable variables%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % QAM Order:
    QAMOrders =  {"16"};
    uicontrol('Style', 'text', 'String', 'QAMOrder', 'Position', [startX, startY + 270, 80, 20]);
    valueInputs.('QAMOrder') = uicontrol('Style', 'popupmenu', 'String', QAMOrders, 'Position', [startX+85, startY + 270, 80, 20], 'Tag', 'QAMOrder_value', 'Callback', @updateSweepInputs);
    
    % Blocker Angle:
    uicontrol('Style', 'text', 'String', 'BlockerAngle', 'Position', [startX+590, startY + 310, 80, 20]);
    %uicontrol('Style', 'text', 'String', 'Value', 'Position', [startX + 635, startY + 310, 40, 20]);
    valueInputs.('BlockerAngle') = uicontrol('Style', 'edit', 'Position', [startX + 680, startY + 310, 60, 25], 'Tag', 'BlockerAngle_value', 'String', num2str(defaultValues.('BlockerAngle')));
 
    %Num Symbols and User Angle Spacing
    nonSweepVars = {'QAMNumSymbols', 'UserAngleSpacing'};
    nVarsNonSweep = length(nonSweepVars);
    for j = 1:nVarsNonSweep
        uicontrol('Style', 'text', 'String', nonSweepVars{j}, 'Position', [startX, startY + 270-(j)*40, 80, 20]);
        % Nominal value input
        uicontrol('Style', 'text', 'String', 'Value', 'Position', [startX + 85, startY + 270-(j)*40, 40, 20]);
        valueInputs.(nonSweepVars{j}) = uicontrol('Style', 'edit', 'Position', [startX + 130, startY + 270-(j)*40, 60, 25], 'Tag', [nonSweepVars{j} '_value'], 'String', num2str(defaultValues.(nonSweepVars{j})));
    end

    % Title for Boolean Variables
    uicontrol('Style', 'text', 'String', 'System Parameters', 'Position', [startX + 750, startY + 400, 140, 20], 'FontWeight', 'bold');

    % Generate GUI elements for booleans (checkboxes)
    checkboxNames = flip(fieldnames(defaultBooleans));
    for i = 1:length(checkboxNames)
        uicontrol('Style', 'checkbox', 'String', checkboxNames{i}, 'Position', [startX + 750, startY + 370-(i-1)*30, 140, 25], 'Tag', checkboxNames{i}, 'Value', defaultBooleans.(checkboxNames{i}));
    end

    % Button to plot
    uicontrol('Style', 'pushbutton', 'String', 'Plot', 'Position', [startX + 350, startY + 10, 100, 30], 'Callback', @plotButtonCallback);
    
    selectedOutput = outputOptions{get(outputDropdown, 'Value')};
    

    presetOptions = ["None", ...
                    "Figure 8a: SNDR vs. SIR with varying B, M=1", ...
                    "Figure 8b: SNDR vs. SIR with varying B, M=16, Conjugate BF", ...
                    "Figure 8c: SNDR vs. SIR with varying B, M=16, Zero-force BF", ...
                    "Figure 9: SNDR vs. SIR with varying B, M=16, Zero-force BF, and thermal noise", ...
                    "Figure 11: SIRmin vs. M with varying B, Zero-force BF", ...
                    "Figure 12: BER vs. SNRTherm for varying B, M=1", ...
                    "Figure 13: BER vs. SNRTherm for varying B, M=16", ...
                    "Figure 14: BER vs. SNRTherm and SIR for varying B, M = 1", ...
                    "Figure 15a: BER vs. SNRTherm and SIR for varying B, M = 16, Conjugate Beamforming", ...
                    "Figure 15b: BER vs. SNRTherm and SIR for varying B, M = 16, Zero-force Beamforming", ...
                    "Figure 16: BER vs. SNRTherm and SIR for varying M, B = 1", ...
                    "Figure 17a: SNDR vs. K, M = 16, B = 5, Zero-force BF", ...
                    "Figure 17b: ENOB vs. K, M = 16, B = 5, Zero-force BF", ...
                    "Figure 18: ENOB vs. K for varying B, M = 16, Zero-force BF", ...
                    "Figure 19: SNDR vs. SIR for varying K, M = 16, B = 5", ...
                    ];
    uicontrol('Style', 'text', 'String', 'Preset', 'Position', [startX, startY + 450, 100, 20]);
    presetDropdown = uicontrol('Style', 'popupmenu', 'String', presetOptions, 'Position', [startX + 110, startY + 450, 100, 25], 'Tag', 'presetDropdown', 'Callback', @setPreset);
    % Get selected output to plot

    %%%%%%%%%%%%%%%%%%%%%
    %Hard-coded presets:%
    %%%%%%%%%%%%%%%%%%%%%
    tags_value = ["outputDropdown", "LogScaleX", "LogScaleY","LogScaleZ", "fitDataCheckbox","QAMOrder_value", ...
            "sweepVar1", "sweepVar2", "sweepVar3", "multCurves2", "multCurves3", ...
            "addThermNoise", "ZFOn", "EnableBlocker", "SweepBlockerAngle", "SweepUserAngle", ...
            ];
    tags_string = ["QAMNumSymbols_value", "BlockerAngle_value", "UserAngleSpacing_value", ...
               "SNRTherm_start", "SNRTherm_end", "SNRTherm_step", "SNRTherm_value", ...
               "SIR_start", "SIR_end", "SIR_step", "SIR_value", ...
               "M_start", "M_end", "M_step", "M_value", ...
               "K_start", "K_end", "K_step", "K_value", ...
               "B_start", "B_end", "B_step", "B_value", ...
               "Angle_start", "Angle_end", "Angle_step", "Angle_value", ...
               ];

    preset1Values = [3, 0, 0, 0, 0, 1, ... 
                     3, 6, 1, 1, 0, ...
                     0, 0, 1, 0, 0, ...
                     ];
    preset1Strings = [1000, 11.25, 22.5, ... %QAM
                     0, 0, 0, 0, ...    %SNRTherm
                     -40, 80, 1, 0, ...     %SIR
                     0, 0, 0, 1, ...    %M
                     0, 0, 0, 2, ...     %K
                     3, 8, 1, 5, ...     %B
                     0, 0, 0, 0,         %Angle
                     ];
    preset2Values = [3, 0, 0, 0, 0, 1, ... 
                     3, 6, 1, 1, 0, ...
                     0, 0, 1, 0, 0, ...
                     ];
    preset2Strings = [1000, 11.25, 22.5, ... %QAM
                     0, 0, 0, 0, ...    %SNRTherm
                     -40, 80, 1, 0, ...     %SIR
                     0, 0, 0, 16, ...    %M
                     0, 0, 0, 2, ...     %K
                     3, 8, 1, 5, ...     %B
                     0, 0, 0, 0,         %Angle
                     ];
    preset3Values = [3, 0, 0, 0, 0, 1, ... 
                     3, 6, 1, 1, 0, ...
                     0, 1, 1, 0, 0, ...
                     ];
    preset3Strings = [1000, 11.25, 22.5, ... %QAM
                     0, 0, 0, 0, ...    %SNRTherm
                     -40, 80, 1, 0, ...     %SIR
                     0, 0, 0, 16, ...    %M
                     0, 0, 0, 2, ...     %K
                     3, 8, 1, 5, ...     %B
                     0, 0, 0, 0,         %Angle
                     ];
    preset4Values = [3, 0, 0, 0, 0, 1, ... 
                     3, 6, 1, 1, 0, ...
                     1, 1, 1, 0, 0, ...
                     ];
    preset4Strings = [1000, 11.25, 22.5, ... %QAM
                     0, 0, 0, 20, ...    %SNRTherm
                     -40, 80, 1, 0, ...     %SIR
                     0, 0, 0, 16, ...    %M
                     0, 0, 0, 2, ...     %K
                     3, 8, 1, 5, ...     %B
                     0, 0, 0, 0,         %Angle
                     ];
    preset5Values = [5, 1, 0, 0, 0, 1, ... 
                     4, 6, 1, 1, 0, ...
                     0, 1, 1, 0, 0, ...
                     ];
    preset5Strings = [1000, 45, 5, ... %QAM
                     0, 0, 0, 0, ...    %SNRTherm
                     -60, 0, 0.25, 0, ...     %SIR
                     4, 32, 4, 16, ...    %M
                     0, 0, 0, 2, ...     %K
                     3, 8, 1, 5, ...     %B
                     0, 0, 0, 0,         %Angle
                     ];

    preset6Values = [1, 0, 1, 0, 0, 1, ... 
                     2, 6, 1, 1, 0, ...
                     1, 1, 0, 0, 0, ...
                     ];
    preset6Strings = [1000, 11.25, 22.5, ... %QAM
                     0, 20, 0.25, 0, ...    %SNRTherm
                     0, 0, 0, 0, ...     %SIR
                     0, 0, 0, 1, ...    %M
                     0, 0, 0, 1, ...     %K
                     1, 8, 1, 5, ...     %B
                     0, 0, 0, 0,         %Angle
                     ];


    preset7Values = [1, 0, 1, 0, 0, 1, ... 
                     2, 6, 1, 1, 0, ...
                     1, 1, 0, 0, 0, ...
                     ];
    preset7Strings = [4000, 11.25, 22.5, ... %QAM
                     0, 20, 0.25, 0, ...    %SNRTherm
                     0, 0, 0, 0, ...     %SIR
                     0, 0, 0, 16, ...    %M
                     0, 0, 0, 1, ...     %K
                     1, 8, 1, 5, ...     %B
                     0, 0, 0, 0,         %Angle
                     ];
    preset8Values = [1, 0, 0, 1, 0, 1, ... 
                     2, 3, 6, 0, 1, ...
                     1, 0, 1, 0, 0, ...
                     ];
    preset8Strings = [4000, 11.25, 22.5, ... %QAM
                     0, 20, 0.25, 0, ...    %SNRTherm
                     -20, 20, 1, 0, ...     %SIR
                     0, 0, 0, 1, ...    %M
                     0, 0, 0, 2, ...     %K
                     3, 6, 1, 5, ...     %B
                     0, 0, 0, 0,         %Angle
                     ];

    preset9Values = [1, 0, 0, 1, 0, 1, ... 
                     2, 3, 6, 0, 1, ...
                     1, 0, 1, 0, 0, ...
                     ];
    preset9Strings = [4000, 11.25, 22.5, ... %QAM
                     0, 20, 0.25, 0, ...    %SNRTherm
                     -20, 20, 1, 0, ...     %SIR
                     0, 0, 0, 16, ...    %M
                     0, 0, 0, 2, ...     %K
                     3, 6, 3, 5, ...     %B
                     0, 0, 0, 0,         %Angle
                     ];
    
    preset10Values = [1, 0, 0, 1, 0, 1, ... 
                     2, 3, 6, 0, 1, ...
                     1, 1, 1, 0, 0, ...
                     ];
    preset10Strings = [4000, 11.25, 22.5, ... %QAM
                     0, 20, 0.25, 0, ...    %SNRTherm
                     -20, 20, 1, 0, ...     %SIR
                     0, 0, 0, 16, ...    %M
                     0, 0, 0, 2, ...     %K
                     3, 6, 3, 5, ...     %B
                     0, 0, 0, 0,         %Angle
                     ];

    preset11Values = [1, 0, 1, 0, 0, 1, ... 
                     2, 4, 1, 1, 0, ...
                     1, 0, 0, 0, 0, ...
                     ];
    preset11Strings = [100000, 11.25, 22.5, ... %QAM
                     0, 20, 0.25, 0, ...    %SNRTherm
                     0, 0, 0, 0, ...     %SIR
                     16, 64, 48, 16, ...    %M
                     0, 0, 0, 1, ...     %K
                     0, 0, 0, 1, ...     %B
                     0, 0, 0, 0,         %Angle
                     ];

    preset12Values = [3, 0, 0, 0, 0, 1, ... 
                     5, 1, 1, 0, 0, ...
                     0, 1, 0, 0, 0, ...
                     ];
    preset12Strings = [10000, 11.25, 22.5, ... %QAM
                     0, 120, 4, 0, ...    %SNRTherm
                     0, 0, 0, 0, ...     %SIR
                     0, 0, 0, 16, ...    %M
                     1, 8, 1, 1, ...     %K
                     0, 0, 0, 5, ...     %B
                     0, 0, 0, 0,         %Angle
                     ];

    preset13Values = [4, 0, 0, 0, 0, 1,... 
                     5, 1, 1, 0, 0, ...
                     0, 1, 0, 0, 0, ...
                     ];
    preset13Strings = [10000, 11.25, 22.5, ... %QAM
                     0, 0, 0, 120, ...    %SNRTherm
                     0, 0, 0, 0, ...     %SIR
                     0, 0, 0, 16, ...    %M
                     1, 8, 1, 1, ...     %K
                     0, 0, 0, 5, ...     %B
                     0, 0, 0, 0,         %Angle
                     ];
    preset14Values = [4, 0, 0, 0, 0, 1,... 
                     5, 6, 1, 1, 0, ...
                     0, 1, 0, 0, 0, ...
                     ];
    preset14Strings = [100000, 11.25, 22.5, ... %QAM
                     0, 0, 0, 120, ...    %SNRTherm
                     0, 0, 0, 0, ...     %SIR
                     0, 0, 0, 16, ...    %M
                     1, 8, 1, 1, ...     %K
                     1, 8, 1, 5, ...     %B
                     0, 0, 0, 0,         %Angle
                     ];
    preset15Values = [3, 0, 0, 0, 0, 1, ... 
                     3, 5, 1, 1, 0, ...
                     1, 1, 1, 0, 0, ...
                     ];
    preset15Strings = [10000, 78.5, 22.5, ... %QAM
                     0, 0, 0, 120, ...    %SNRTherm
                     -60, 60, 4, 0, ...     %SIR
                     0, 0, 0, 16, ...    %M
                     1, 8, 1, 1, ...     %K
                     0, 0, 0, 5, ...     %B
                     0, 0, 0, 0,         %Angle
                     ];


    preset1 = {dictionary(tags_value, preset1Values), dictionary(tags_string, preset1Strings)};
    preset2 = {dictionary(tags_value, preset2Values), dictionary(tags_string, preset2Strings)};
    preset3 = {dictionary(tags_value, preset3Values), dictionary(tags_string, preset3Strings)};
    preset4 = {dictionary(tags_value, preset4Values), dictionary(tags_string, preset4Strings)};
    preset5 = {dictionary(tags_value, preset5Values), dictionary(tags_string, preset5Strings)};
    preset6 = {dictionary(tags_value, preset6Values), dictionary(tags_string, preset6Strings)};
    preset7 = {dictionary(tags_value, preset7Values), dictionary(tags_string, preset7Strings)};
    preset8 = {dictionary(tags_value, preset8Values), dictionary(tags_string, preset8Strings)};
    preset9 = {dictionary(tags_value, preset9Values), dictionary(tags_string, preset9Strings)};
    preset10 = {dictionary(tags_value, preset10Values), dictionary(tags_string, preset10Strings)};
    preset11 = {dictionary(tags_value, preset11Values), dictionary(tags_string, preset11Strings)};
    preset12 = {dictionary(tags_value, preset12Values), dictionary(tags_string, preset12Strings)};
    preset13 = {dictionary(tags_value, preset13Values), dictionary(tags_string, preset13Strings)};
    preset14 = {dictionary(tags_value, preset14Values), dictionary(tags_string, preset14Strings)};
    preset15 = {dictionary(tags_value, preset15Values), dictionary(tags_string, preset15Strings)};
    presetDicts = {dictionary(), preset1, preset2, preset3, preset4, preset5, preset6, preset7, ...
        preset8, preset9, preset10, preset11, preset12, preset13, preset14, preset15};
    presets = dictionary(presetOptions, presetDicts);


    function setPreset(~,~)
        selectedPreset = presetOptions{get(presetDropdown, 'Value')};
        if selectedPreset ~= "None"
            presetDicts = presets(selectedPreset);
            presetDicts = presetDicts{1};
            presetValueDict = presetDicts{1};
            presetStringDict = presetDicts{2};

            presetValueTags = keys(presetValueDict);
            for m = 1:length(presetValueTags)
                tag = presetValueTags(m);
                set(findobj('Tag', tag), 'Value', presetValueDict(tag));
            end

            presetStringTags = keys(presetStringDict);
            for m = 1:length(presetStringTags)
                tag = presetStringTags(m);
                set(findobj('Tag', tag), 'String', presetStringDict(tag));
            end
        end
        updateSweepInputs();
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Update sweep inputs visibility based on selected variables%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function updateSweepInputs(~, ~)
        selectedOutput = outputOptions{get(outputDropdown, 'Value')};
        % Reset visibility

        for i = 1:nVars
            set(sweepInputs.(sweepVars{i}).start, 'Visible', 'off');
            set(findobj('Tag', [sweepVars{i} '_to']), 'Visible', 'off');
            set(sweepInputs.(sweepVars{i}).end, 'Visible', 'off');
            set(findobj('Tag', [sweepVars{i} '_stepLabel']), 'Visible', 'off');
            set(sweepInputs.(sweepVars{i}).step, 'Visible', 'off');
        end
        
        
        % Get selected sweep variables
        sweepVarsSelected = {varNamesWithNone{get(sweepVar1Dropdown, 'Value')}, ...
                             varNamesWithNone{get(sweepVar2Dropdown, 'Value')}, ...
                             varNamesWithNone{get(sweepVar3Dropdown, 'Value')}};
        
        % Update visibility for the selected sweep variables
        for i = 1:3 %Three total sweep vars
            if ~strcmp(sweepVarsSelected{i}, 'None')
                set(sweepInputs.(sweepVarsSelected{i}).start, 'Visible', 'on');
                set(findobj('Tag', [sweepVarsSelected{i} '_to']), 'Visible', 'on');
                set(sweepInputs.(sweepVarsSelected{i}).end, 'Visible', 'on');
                set(findobj('Tag', [sweepVarsSelected{i} '_stepLabel']), 'Visible', 'on');
                set(sweepInputs.(sweepVarsSelected{i}).step, 'Visible', 'on');
            end
        end

        if strcmp(selectedOutput, 'Minimum SIR')
            set(sweepInputs.('SIR').start, 'Visible', 'on');
            set(findobj('Tag', 'SIR_to'), 'Visible', 'on');
            set(sweepInputs.('SIR').end, 'Visible', 'on');
            set(findobj('Tag', 'SIR_stepLabel'), 'Visible', 'on');
            set(sweepInputs.('SIR').step, 'Visible', 'on');
        end

    end

    function plotButtonCallback(~, ~)
        selectedOutput = outputOptions{get(outputDropdown, 'Value')};

        % Get selected sweep variables
        sweepVar1 = varNamesWithNone{get(sweepVar1Dropdown, 'Value')};
        sweepVar2 = varNamesWithNone{get(sweepVar2Dropdown, 'Value')};
        sweepVar3 = varNamesWithNone{get(sweepVar3Dropdown, 'Value')};

        if strcmp(sweepVar1, 'None'), sweepVar1 = ''; end
        if strcmp(sweepVar2, 'None'), sweepVar2 = ''; end
        if strcmp(sweepVar3, 'None'), sweepVar3 = ''; end

        multCurves2 = get(multCurves2Checkbox, 'Value');
        multCurves3 = get(multCurves3Checkbox, 'Value');

        sweepRanges = struct();
        finalValues = struct();

        % Assign values to sweep ranges and final values
        for i = 1:nVars
            varName = sweepVars{i};
            if strcmp(sweepVar1, varName) || strcmp(sweepVar2, varName) || strcmp(sweepVar3, varName)
                % If the variable is a sweep variable, get the range
                sweepRanges.(varName) = str2double(get(sweepInputs.(varName).start, 'String')):...
                                         str2double(get(sweepInputs.(varName).step, 'String')):...
                                         str2double(get(sweepInputs.(varName).end, 'String'));
            else
                if ~(strcmp(selectedOutput, 'Minimum SIR') && strcmp(varName, 'SIR'))
                    finalValues.(varName) = str2double(get(valueInputs.(varName), 'String'));
                end
                % Otherwise, just get the fixed value
            end
        end

        if strcmp(selectedOutput, 'Minimum SIR')
            sweepRanges.('SIR') = str2double(get(sweepInputs.('SIR').start, 'String')):...
                                  str2double(get(sweepInputs.('SIR').step, 'String')):...
                                  str2double(get(sweepInputs.('SIR').end, 'String'));
        end


        
        for j = 1:nVarsNonSweep 
            varName = nonSweepVars{j};
            finalValues.(varName) = str2double(get(valueInputs.(varName), 'String'));
        end
        finalValues.('QAMOrder') = str2double(QAMOrders{get(findobj('Tag', 'QAMOrder_value'), 'Value')});
        finalValues.('BlockerAngle') = str2double(get(valueInputs.('BlockerAngle'), 'String'));
        % Boolean variables (System Parameters)
        for i = 1:length(checkboxNames)
            finalValues.(checkboxNames{i}) = get(findobj('Tag', checkboxNames{i}), 'Value');
        end

        % Boolean variables (Logs)
        for i = 1:length(logsNames)
            finalValues.(logsNames{i}) = get(findobj('Tag', logsNames{i}), 'Value');
        end

        try
            MSweep = finalValues.('M');
        end
        try
            KSweep = finalValues.('K');
        end
        try
            BSweep = finalValues.('B');
        end
        try
            SBRsdBSweep = finalValues.('SIR');
        end
        try
            SNRThermSweep = finalValues.('SNRTherm');
        end
        try
            AngleSweep = finalValues.('Angle');
        end
        %If any of the sweep variables are indeed swept, update their
        %values to the corresponding range of values
        SweptVars = [{sweepVar1}, {sweepVar2}, {sweepVar3}];
        UnsweptVars = setdiff(sweepVars, SweptVars);
        for j = 1:length(SweptVars)
            SweptVar = SweptVars(j);
            if strcmp(SweptVar, 'M')
                MSweep = sweepRanges.(cell2mat(SweptVar));
            elseif strcmp(SweptVar, 'K')
                KSweep = sweepRanges.(cell2mat(SweptVar));
            elseif strcmp(SweptVar, 'B')
                BSweep = sweepRanges.(cell2mat(SweptVar));
            elseif strcmp(SweptVar, 'SIR')
                SBRsdBSweep = sweepRanges.(cell2mat(SweptVar));
            elseif strcmp(SweptVar, 'SNRTherm')
                SNRThermSweep = sweepRanges.(cell2mat(SweptVar));
            elseif strcmp(SweptVar, 'Angle')
                AngleSweep = sweepRanges.(cell2mat(SweptVar));
            end
        end
        
         %To output Minimum SIR, the SIR must be swept in addition to the
         %other swept variables
         if strcmp(selectedOutput, 'Minimum SIR')
            SBRsdBSweep = sweepRanges.('SIR');
         end 


        %Set the values of all non-sweepable variables
        addThermNoise = finalValues.('addThermNoise');
        ZF = finalValues.('ZFOn');
        EnableBlocker = finalValues.('EnableBlocker');
        SweepBlockerAngle = finalValues.('SweepBlockerAngle');
        SweepUserAngle = finalValues.('SweepUserAngle');
        BlockerAngle = finalValues.('BlockerAngle');
        UserAngleSpacing = finalValues.('UserAngleSpacing');
        QAMOrder = finalValues.('QAMOrder');
        QAMNumSymbols = finalValues.('QAMNumSymbols');


        % Get selected output to plot
        selectedOutput = outputOptions{get(outputDropdown, 'Value')};

        % Check if "Fit data" checkbox is selected
        fitData = get(fitDataCheckbox, 'Value');


        %Run the beamforming model to generate outputs
        [ENOBs, BERs, EVMs, SNDRsMeasured, SBRminsdB, ArrayGainMeasured] = DBF_General(MSweep, KSweep, BSweep, SBRsdBSweep, ...
            SNRThermSweep, AngleSweep, addThermNoise, ZF, EnableBlocker, ...
                            SweepBlockerAngle, SweepUserAngle, BlockerAngle, UserAngleSpacing, QAMOrder, QAMNumSymbols);


        %Permute the dimensions of all outputs such that the first four dimensions are
        %always uIdx, SweepVar1, SweepVar2, SweepVar3
        %This is necessary because the plot_results function assumes that
        %the first four dimensions are in that order. 
        VarToDim = dictionary([{'M'}, {'K'}, {'B'}, {'SIR'}, {'SNRTherm'}, {'Angle'}], 2:7);
        VarToDimSBRmin = dictionary([{'M'}, {'K'}, {'B'}, {'SNRTherm'}, {'Angle'}, {'SIR'}], [2:6, 0]);
    
        permuteOrder = [1, VarToDim([SweptVars(find(~cellfun(@isempty,SweptVars))), UnsweptVars])];

        BERsPermuted = permute(BERs, permuteOrder);
        EVMsPermuted = permute(EVMs, permuteOrder);
        SNDRsMeasuredPermuted = permute(SNDRsMeasured, permuteOrder);
        ENOBsPermuted = permute(ENOBs, permuteOrder);
        ArrayGainMeasuredPermuted = permute(ArrayGainMeasured, permuteOrder);

        %%Need to remove SIR form SweptVars here...
        permuteOrder = [1, VarToDimSBRmin([SweptVars(find(~cellfun(@isempty,SweptVars))), UnsweptVars])];
        permuteOrder = permuteOrder(permuteOrder ~=0); %remove the SIR dimension from SIRmin measurement
        SBRminsdBPermuted = permute(SBRminsdB, permuteOrder);
        

        % Get output data
        OutputDict = dictionary(outputOptions, {BERsPermuted, EVMsPermuted, SNDRsMeasuredPermuted, ENOBsPermuted, SBRminsdBPermuted, ArrayGainMeasuredPermuted});
        Output = cell2mat(OutputDict({selectedOutput}));

        % Plot the results
        plot_results(sweepRanges, finalValues, sweepVar1, sweepVar2, sweepVar3, multCurves2, multCurves3, selectedOutput, Output, fitData);

    end
end

function plot_results(sweepRanges, finalValues, sweepVar1, sweepVar2, sweepVar3, multCurves2, multCurves3, selectedOutput, Output, fitData)
    
    logX = finalValues.('LogScaleX');
    logY = finalValues.('LogScaleY');
    logZ = finalValues.('LogScaleZ');
    QAMOrder = finalValues.('QAMOrder');
    QAMNumSymbols = finalValues.('QAMNumSymbols');    


    if finalValues.SweepUserAngle 
        VarToLabel = dictionary([{'M'}, {'K'}, {'B'}, {'SIR'}, {'SNRTherm'}, {'Angle'}], ...
                                [{'M ($\#$ Elements)'}, {'K ($\#$ Users)'}, {'B ($\#$ bits)'}, {'SIR (dB)'}, {'$SNR_{therm}$ (dB)'}, {'User Angle Spacing ($^{\circ}$)'}]);
    elseif finalValues.SweepBlockerAngle
        VarToLabel = dictionary([{'M'}, {'K'}, {'B'}, {'SIR'}, {'SNRTherm'}, {'Angle'}], ...
                                [{'M ($\#$ Elements)'}, {'K ($\#$ Users)'}, {'B ($\#$ bits)'}, {'SIR (dB)'}, {'$SNR_{therm}$ (dB)'}, {'Blocker Angle ($^{\circ}$)'}]);
    else
        VarToLabel = dictionary([{'M'}, {'K'}, {'B'}, {'SIR'}, {'SNRTherm'}, {'Angle'}], ...
                        [{'M ($\#$ Elements)'}, {'K ($\#$ Users)'}, {'B ($\#$ bits)'}, {'SIR (dB)'}, {'$SNR_{therm}$ (dB)'}, {'Angle ($^{\circ}$)'}]);
    end
    OutToLabel = dictionary([{'BER'}, {'SNDR'}, {'EVM'}, {'ENOB'}, {'Minimum SIR'}, {'Array Gain'}], ...
                            [{'BER'}, {'SNDR (dB)'}, {'EVM ($\%$ RMS)'}, {'ENOB'}, {'Minimum SIR (dB)'}, {'Measured Array Gain (dB)'}]);

    SweptVars = [{sweepVar1}, {sweepVar2}, {sweepVar3}];
    UnsweptVars = setdiff(VarToLabel.keys, SweptVars);
    
    mysubtitle = strcat('$\vert$ ', num2str(QAMOrder), '-QAM', '  $\vert$  ', '');
    for varIdx = 1:length(UnsweptVars)
        VarName = UnsweptVars(varIdx); 
       if ~(strcmp(cell2mat(VarName), 'SIR') && strcmp(selectedOutput, 'Minimum SIR'))%If plotting Minimum SIR, SIR is actually a swept variable, so dont add to title
           if ~strcmp(cell2mat(VarName), 'Angle') 
                if strcmp(cell2mat(VarName), 'SIR') 
                    if finalValues.EnableBlocker
                        VarLabel = cell2mat(VarToLabel(VarName));
                        mysubtitle = strcat(mysubtitle, VarLabel, ": ", num2str(finalValues.(cell2mat(VarName))), "  $\vert$  ");
                    end
                elseif strcmp(cell2mat(VarName), 'SNRTherm')
                    if finalValues.addThermNoise
                        VarLabel = cell2mat(VarToLabel(VarName));
                        mysubtitle = strcat(mysubtitle, VarLabel, ": ", num2str(finalValues.(cell2mat(VarName))), "  $\vert$  ");
                    end
                else
                    VarLabel = cell2mat(VarToLabel(VarName));
                    mysubtitle = strcat(mysubtitle, VarLabel, ": ", num2str(finalValues.(cell2mat(VarName))), "  $\vert$  ");
                end
           end
       end
    end




    OutLabel = cell2mat(OutToLabel({selectedOutput}));
    try
        Var1Label = cell2mat(VarToLabel({sweepVar1}));
    end
    try
        Var2Label = cell2mat(VarToLabel({sweepVar2}));
    end
    try
        Var3Label = cell2mat(VarToLabel({sweepVar3}));
    end
    polyOrder = 12;
    

    uIdx = 1;
    
    % Plot based on selected variables
    if isempty(sweepVar2) && isempty(sweepVar3)
        figure();
        % 1D plot with one sweep variable
        xData = sweepRanges.(sweepVar1);
        yData = squeeze(Output(uIdx,:));


        % Plot original data and fitted curve
        hold on;
        if fitData
            % Fit the data using polyfit
            p = polyfit(xData, yData, polyOrder);  % Fit a quadratic curve (adjust degree as needed)
            yFit = polyval(p, xData);
            plot(xData, yData, '.k');
            plot(xData, yFit, '-k');
        else
            plot(xData, yData, '.-k');
        end
        hold off;
        xlabel(Var1Label); ylabel(OutLabel);
        title([OutLabel, ' vs. ' Var1Label]);
        %subtitle([num2str(QAMOrder), '-QAM ', num2str(QAMNumSymbols), ' Symbols per run']);
        subtitle(mysubtitle);
        setLogAxes(logX, logY, logZ);



    elseif isempty(sweepVar3)
        % 2D plot or multiple curves with two sweep variables
        if multCurves2
            figure;
            hold on;
            v2Range = sweepRanges.(sweepVar2);
            colors = colormap(hsv(length(v2Range)));
            xData = sweepRanges.(sweepVar1);
            for v2Idx = 1:length(v2Range)
                v2 = v2Range(v2Idx);
                yData = squeeze(Output(uIdx,:, v2Idx));
                
                if fitData
                    % Fit the data using polyfit
                    p = polyfit(xData, yData, polyOrder);  % Fit a quadratic curve (adjust degree as needed)
                    yFit = polyval(p, xData);
                    plot(xData, yData, '.', 'Color', colors(v2Idx,:), 'DisplayName', [sweepVar2 ' = ' num2str(v2)]);
                    plot(xData, yFit, '-', 'Color', colors(v2Idx,:),'HandleVisibility', 'off');
                else
                    plot(xData, yData, '.-', 'Color', colors(v2Idx,:), 'DisplayName', [sweepVar2 ' = ' num2str(v2)]);
                end    
            end
            hold off;
            legend("Location", "best");

            xlabel(Var1Label); ylabel(OutLabel);
            title([OutLabel ' vs. ' Var1Label ' with varying ' Var2Label], ...
                "Interpreter", "latex");
            %subtitle([num2str(QAMOrder), '-QAM ', num2str(QAMNumSymbols), ' Symbols per run']);
            subtitle(mysubtitle);
            setLogAxes(logX, logY, logZ);

        else
            [X, Y] = meshgrid(sweepRanges.(sweepVar1), sweepRanges.(sweepVar2));
            zData = squeeze(Output(uIdx,:, :)).';
            figure; 
            if fitData 
                ft = fittype('poly44'); % Polynomial of degree 2 in x and y
                fitResult = fit([X(:), Y(:)], zData(:), ft);
                zFit = reshape(fitResult(X(:), Y(:)), size(X));
                surf(X, Y, zFit, 'EdgeColor', 'k', 'FaceColor', 'k', 'FaceAlpha', 0.5);
            else
                surf(X, Y, zData, 'EdgeColor', 'k', 'FaceColor', 'k', 'FaceAlpha', 0.5);
            end


            
            xlabel(Var1Label); ylabel(Var2Label); zlabel(OutLabel);
            title([OutLabel, ' vs. ' Var1Label ' and ' Var2Label]);
            %subtitle([num2str(QAMOrder), '-QAM ', num2str(QAMNumSymbols), ' Symbols per run']);
            subtitle(mysubtitle);
            setLogAxes(logX, logY, logZ);

        end

    else
        if multCurves3
            
            figure();
            hold on;
            v3Range = sweepRanges.(sweepVar3);
            colors = colormap(hsv(length(v3Range)));
            for v3Idx = 1:length(v3Range)
                v3 = v3Range(v3Idx);
                [X, Y] = meshgrid(sweepRanges.(sweepVar1), sweepRanges.(sweepVar2));
                zData = squeeze(Output(uIdx,:, :, v3Idx)).';
                
                if fitData 
                    ft = fittype('poly44'); % Polynomial of degree 2 in x and y
                    fitResult = fit([X(:), Y(:)], zData(:), ft);
                    zFit = reshape(fitResult(X(:), Y(:)), size(X));
                    surf(X, Y, zFit, 'EdgeColor', colors(v3Idx,:),'FaceColor', colors(v3Idx,:), 'FaceAlpha', 0.5, 'DisplayName', [sweepVar3 ' = ' num2str(v3)]);
                else
                    surf(X, Y, zData, 'EdgeColor', colors(v3Idx,:),'FaceColor', colors(v3Idx,:), 'FaceAlpha', 0.5, 'DisplayName', [sweepVar3 ' = ' num2str(v3)]);
                end
                hold on;
            end
            hold off;
            legend("Location", "best");
            xlabel(Var1Label); ylabel(Var2Label); zlabel(OutLabel);
            title([OutLabel, ' vs. ' Var1Label ' and ' Var2Label ' with varying ' Var3Label]);
            %subtitle([num2str(QAMOrder), '-QAM ', num2str(QAMNumSymbols), ' Symbols per run']);
            subtitle(mysubtitle);
            setLogAxes(logX, logY, logZ);

        else
            [X, Y, Z] = ndgrid(sweepRanges.(sweepVar1), sweepRanges.(sweepVar2), sweepRanges.(sweepVar3));
            result = squeeze(Output(uIdx,:, :, :));
            figure; 
            for v3 = sweepRanges.(sweepVar3)
                slice(X, Y, Z, result, [], [], v3);
            end
            xlabel(Var1Label); ylabel(Var2Label); zlabel(Var3Label);
            title(['foo output vs. ' Var1Label ', ' Var2Label ', and ' Var3Label]);
            %subtitle([num2str(QAMOrder), '-QAM ', num2str(QAMNumSymbols), ' Symbols per run']);
            subtitle(mysubtitle);
            setLogAxes(logX, logY, logZ);

        end
    end

    disp(['Plotting ', selectedOutput, '...']);

    
end

%%
function [ENOBs, BERs, EVMs, SNDRsMeasured, SBRminsdB, ArrayGainMeasured] = DBF_General(MSweep, KSweep, BSweep, SBRsdBSweep, ...
    SNRThermSweep, AngleSweep, addThermNoise, ZF, EnableBlocker, ...
                    SweepBlockerAngle, SweepUserAngle, BlockerAngle, UserAngleSpacing, QAMOrder, QAMNumSymbols)

    %%%%%%%%%%%%%%%%%%%
    %Sweepable Inputs %
    %%%%%%%%%%%%%%%%%%%
    inp.MSweep = MSweep; %Number of RX Antennas
    inp.KSweep = KSweep; % Number of users
    
    inp.BSweep = BSweep;  % ADC Resolution
    inp.SBRsdBSweep = SBRsdBSweep;
    inp.SNRThermSweep = SNRThermSweep; %dB
    inp.AngleSweep = AngleSweep;

    %%%%%%%%%
    %Inputs %
    %%%%%%%%%
    
    inp.addThermNoise = addThermNoise; %add_therm_noise = 1;
    inp.ZF = ZF; %1 for Zero-Forcing, 0 for Conjugate beamforming
    inp.EnableBlocker = EnableBlocker;
    inp.SweepBlockerAngle = SweepBlockerAngle; %1 or 0
    inp.SweepUserAngle = SweepUserAngle;  %1 or 0
    
    inp.BlockerAngle = BlockerAngle; %degrees
    inp.UserAngleSpacing = UserAngleSpacing; %degrees  
    
    inp.qam_M = QAMOrder;
    inp.num_symbols = QAMNumSymbols;

    
    %%%%%%%%%%%%%%%%%%%%
    %General Parameters%
    %%%%%%%%%%%%%%%%%%%%
    prm.fc = 20e9;               % Carrier Frequency (used for Path Loss)
    prm.d_lambda = 1/2;            % Element Spacing nomalized to lambda
    
    prm.cLight = physconst('LightSpeed');
    prm.lambda = prm.cLight/prm.fc;
    
    %%%%%%%%%%%%%%%%%%
    %Array Parameters%
    %%%%%%%%%%%%%%%%%%
    prm.posRx = [0;0;0];       % BS/Receive array position, [x;y;z], meters
    
    %%%%%%%%%%%%%%%%
    %TX/RX Parameters%
    %%%%%%%%%%%%%%%%
    prm.rxGain = 30; %LNA gain, not tunable

    
    %%%%%%%%%%%%%%%%%%%
    %QAMMOD Parameters%
    %%%%%%%%%%%%%%%%%%%
    prm.qam_K = log2(inp.qam_M);
    prm.num_samples = inp.num_symbols * prm.qam_K;

    prm.lengthTxSigsData = inp.num_symbols;
    prm.lengthRxSigsData = inp.num_symbols;

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initializing Angle Sweep Matrices %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if any([inp.SweepBlockerAngle, inp.SweepUserAngle])
        prm.NumPointsAngleSweep = length(inp.AngleSweep);
    else
        prm.NumPointsAngleSweep = 1;
    end
    BlockerTXGainsdB = -1*inp.SBRsdBSweep;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initializing TX Output and Channel Matrices %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TXGains = zeros(max(inp.KSweep), length(inp.KSweep), length(inp.SBRsdBSweep));
    txData = zeros(prm.num_samples, max(inp.KSweep), length(inp.KSweep), length(inp.SBRsdBSweep));
    txQamData = zeros(inp.num_symbols, max(inp.KSweep), length(inp.KSweep), length(inp.SBRsdBSweep));
    txQamDataPAOut =zeros(inp.num_symbols,max(inp.KSweep), length(inp.KSweep), length(inp.SBRsdBSweep));
    txSigs = zeros(prm.lengthTxSigsData, max(inp.KSweep), length(inp.KSweep), length(inp.SBRsdBSweep));
    rxSigsAnt = zeros(max(inp.MSweep),prm.lengthTxSigsData, length(inp.MSweep), ...
        length(inp.KSweep), length(inp.SBRsdBSweep), prm.NumPointsAngleSweep);
    ChannelMtxs = zeros(max(inp.MSweep), max(inp.KSweep), length(inp.MSweep), length(inp.KSweep), prm.NumPointsAngleSweep);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initializing RX Output Matrices %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    evm = comm.EVM;
    BERs = zeros(max(inp.KSweep),length(inp.MSweep), length(inp.KSweep), length(inp.BSweep), ...
        length(inp.SBRsdBSweep), length(inp.SNRThermSweep), prm.NumPointsAngleSweep);
    EVMs = zeros(max(inp.KSweep),length(inp.MSweep), length(inp.KSweep), length(inp.BSweep), ...
        length(inp.SBRsdBSweep), length(inp.SNRThermSweep), prm.NumPointsAngleSweep);
    SNDRsMeasured = zeros(max(inp.KSweep),length(inp.MSweep), length(inp.KSweep), length(inp.BSweep), ...
        length(inp.SBRsdBSweep), length(inp.SNRThermSweep), prm.NumPointsAngleSweep);
    ArrayGainMeasured = zeros(max(inp.KSweep),length(inp.MSweep), length(inp.KSweep), length(inp.BSweep), ...
        length(inp.SBRsdBSweep), length(inp.SNRThermSweep), prm.NumPointsAngleSweep);
    SBRminsdB = zeros(max(inp.KSweep),length(inp.MSweep), length(inp.KSweep), length(inp.BSweep), ...
        length(inp.SNRThermSweep), prm.NumPointsAngleSweep);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Set a fixed, but random initial seed for noise and data RNG streams%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    randNum = 10;

    for KIdx = 1:length(inp.KSweep)
        prm.numUsers = inp.KSweep(KIdx);
        %%%%%%%%%%%%%%%%%%
        % Mobile positions 
        %%%%%%%%%%%%%%%%%%
        if any([inp.SweepBlockerAngle, inp.SweepUserAngle])
            if inp.SweepBlockerAngle == 1 %If sweeping Blocker Angle
               UserAngles = inp.UserAngleSpacing*[1:prm.numUsers]; %start at -90
               prm.mobileAnglesAz = repmat(UserAngles,length(inp.AngleSweep), 1);
               prm.mobileAnglesAz(:,end) =  inp.AngleSweep.';
            else %If sweeping User Angle (or if both are selected, Blocker Angle is swept by default)
               if inp.EnableBlocker == 1
                   
                   prm.mobileAnglesAz = [inp.AngleSweep.'*[1:prm.numUsers-1], repmat(inp.BlockerAngle, length(inp.AngleSweep),1)];
               else
                   prm.mobileAnglesAz = inp.AngleSweep.'*[1:prm.numUsers];
               end
            end
        else %If not sweeping either angle
            if inp.UserAngleSpacing == 0
                prm.mobileAnglesAz = zeros(1,prm.numUsers); 
            else
               evenUsers = (mod(prm.numUsers, 2) == 0); %if even # users
               if evenUsers
                   thetaStart = -(prm.numUsers/2 + 1/2)*inp.UserAngleSpacing; 
                   prm.mobileAnglesAz = inp.UserAngleSpacing*[1:prm.numUsers] +thetaStart;
               else
                   if prm.numUsers == 1
                        prm.mobileAnglesAz = -inp.UserAngleSpacing/2;
                   else
                       thetaStart = -((prm.numUsers+1)/2 + 1/2)*inp.UserAngleSpacing; %same scheme as the previous even #, just ignore the last user
                       prm.mobileAnglesAz = inp.UserAngleSpacing*[1:prm.numUsers] +thetaStart;
                   end    
               end
               disp(["Angles before permuting: ", prm.mobileAnglesAz]);
               % reindex (permute) the angles such that when K is varied, a
               % given user index (uIdx) corresponds to the same angle

               first_half = 1:1:round(prm.numUsers/2); %i.e 1,2,3,4
               second_half = round(prm.numUsers/2)+1:1:prm.numUsers; %i.e. 5,6,7

               if evenUsers == 1
                   new_indices = [flip(first_half); second_half];
                   new_indices = new_indices(:)';
               else
                    second_half = [second_half, prm.numUsers+1];
                    new_indices = [flip(first_half); second_half];
                    new_indices = new_indices(:)';
                    new_indices = new_indices(1:end-1);
               end
               prm.mobileAnglesAz = prm.mobileAnglesAz(new_indices);
               disp(["Angles after permuting: ", prm.mobileAnglesAz]);
            end
           if inp.EnableBlocker == 1 && prm.numUsers > 1
                prm.mobileAnglesAz(end) = inp.BlockerAngle;
           end
           disp(["Angles with Blocker: ", prm.mobileAnglesAz]);
        end

        prm.mobileRanges = (0.5*ones(size(prm.mobileAnglesAz)));
        prm.mobileAnglesEl = zeros(size(prm.mobileAnglesAz));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Transmit Data: Array Initialization%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        for SIRIdx = 1:length(inp.SBRsdBSweep)
                BlockerTXGaindB = BlockerTXGainsdB(SIRIdx);
                if inp.EnableBlocker == 1
                    TXGainsdB = [zeros(1,prm.numUsers-1), BlockerTXGaindB];
                else
                    TXGainsdB = [zeros(1,prm.numUsers)];
                end
                TXGains(1:prm.numUsers, KIdx, SIRIdx) = 10.^((TXGainsdB)/10);
            for uIdx = 1:prm.numUsers
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % TX Signal (Complex Envelope) Definition/Generation%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                stream = RandStream('mt19937ar', 'Seed', uIdx+randNum); % Independent stream per iteration
                data = randi(stream, [0, 1], prm.num_samples, 1);
                txData(:, uIdx, KIdx, SIRIdx) = data;
                qam_data = qammod(data, inp.qam_M, InputType = "bit", UnitAveragePower = true);
                txQamData(:, uIdx, KIdx, SIRIdx) = qam_data;                   
                txQamDataPAOut(:, uIdx, KIdx, SIRIdx) = sqrt(TXGains(uIdx, KIdx, SIRIdx))*qam_data;
                txSigs(:, uIdx, KIdx, SIRIdx) = txQamDataPAOut(:, uIdx, KIdx, SIRIdx);
            end
        
            spLosses = zeros(prm.NumPointsAngleSweep, prm.numUsers); %Free-space path loss for each user
            for MIdx = 1:length(inp.MSweep)
                prm.numRx = inp.MSweep(MIdx);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Transmit Arrays Placement and Definition%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for AngleIdx = 1:prm.NumPointsAngleSweep
                    ChannelMtx = zeros(prm.numRx, prm.numUsers);
                    for uIdx = 1:prm.numUsers
                        [xTx,yTx,zTx] = sph2cart(deg2rad(prm.mobileAnglesAz(AngleIdx,uIdx)), ...
                                                 deg2rad(prm.mobileAnglesEl(AngleIdx,uIdx)), ...
                                                 prm.mobileRanges(AngleIdx,uIdx));
                        prm.posTx = [xTx;yTx;zTx];                
                        [toRxRange,toRxAng] = rangeangle(prm.posRx, prm.posTx); 
                        spLosses(AngleIdx, uIdx) = fspl(toRxRange,prm.lambda);
        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % MU-MIMO Channel Modeling (modeled as many SIMO channels)
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
                
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % Channel Model #3: Simple Angle of Arrival/Beamforming Model
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        k = 2*pi/prm.lambda;
                        theta = deg2rad(prm.mobileAnglesAz(AngleIdx, uIdx)); %Angle of Arrival
                        psi = 1j*k*prm.lambda*prm.d_lambda*sin(theta) * [0:prm.numRx-1]; %Phase shift due to AoA
                        fadeSig = 1/sqrt(db2pow(spLosses(AngleIdx, uIdx))); %account for path loss
                        ChannelMtx(:, uIdx) = fadeSig*exp(psi); %Channel matrix containing path loss, phase shift
                    end
                    ChannelMtxs(1:prm.numRx, 1:prm.numUsers, MIdx, KIdx, AngleIdx) = ChannelMtx;
                    rxSigsAnt(1:prm.numRx,:, MIdx, KIdx, SIRIdx, AngleIdx) = ChannelMtx*txSigs(:, 1:prm.numUsers, KIdx, SIRIdx).';
                end
            end
        end
    end
                   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Receiver: Matrix Initialization
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    rxSigLNAOut = zeros(max(inp.MSweep), prm.lengthTxSigsData, length(inp.MSweep), length(inp.KSweep), ... 
        length(inp.SBRsdBSweep), length(inp.SNRThermSweep),prm.NumPointsAngleSweep);
    
    rxSigVGAOut = zeros(max(inp.MSweep), prm.lengthTxSigsData, length(inp.MSweep), length(inp.KSweep), ... 
        length(inp.SBRsdBSweep), length(inp.SNRThermSweep),prm.NumPointsAngleSweep);
    
    rxSigFiltOut = zeros(max(inp.MSweep), prm.lengthRxSigsData, length(inp.MSweep), length(inp.KSweep), ... 
        length(inp.SBRsdBSweep), length(inp.SNRThermSweep),prm.NumPointsAngleSweep);
    
    rxSigADCOut = zeros(max(inp.MSweep), prm.lengthRxSigsData, length(inp.MSweep), length(inp.KSweep), ... 
        length(inp.BSweep), length(inp.SBRsdBSweep), length(inp.SNRThermSweep),prm.NumPointsAngleSweep);
    
    rxSigsCombDBF = zeros(max(inp.KSweep), prm.lengthRxSigsData, length(inp.MSweep), length(inp.KSweep), ... 
        length(inp.BSweep), length(inp.SBRsdBSweep), length(inp.SNRThermSweep),prm.NumPointsAngleSweep);
    
    rxSigsCombDBFNorm = zeros(max(inp.KSweep), prm.lengthRxSigsData, length(inp.MSweep), length(inp.KSweep), ... 
        length(inp.BSweep), length(inp.SBRsdBSweep), length(inp.SNRThermSweep),prm.NumPointsAngleSweep);
    
    rxSigsCombDBFDemod = zeros(max(inp.KSweep), prm.num_samples, length(inp.MSweep), length(inp.KSweep), ... 
        length(inp.BSweep), length(inp.SBRsdBSweep), length(inp.SNRThermSweep),prm.NumPointsAngleSweep);
    
    
    for MIdx = 1:length(inp.MSweep)
        disp(["Currently on: M = ", inp.MSweep(MIdx)]);
        prm.numRx = inp.MSweep(MIdx);
        for KIdx = 1:length(inp.KSweep)
            prm.numUsers = inp.KSweep(KIdx);
            for AngleIdx = 1:prm.NumPointsAngleSweep
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Beamforming Matrix Generation                  %
                %Generate Zero-Forcing and Conjugate BF matrices%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                ChannelMtx = ChannelMtxs(1:prm.numRx,1:prm.numUsers, MIdx, KIdx, AngleIdx);
                GrxZF = inv(ctranspose(ChannelMtx)*ChannelMtx)*ctranspose(ChannelMtx);
                GrxConj = ctranspose(ChannelMtx);
                for SNRThermIdx = 1:length(inp.SNRThermSweep)
                        SNRTherm = inp.SNRThermSweep(SNRThermIdx);
                    for SIRIdx = 1:length(inp.SBRsdBSweep)
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % Other users and blocker power should not be accounted for in
                        % our calculation of rxSigPower. Since these uncorrelated
                        % signals sum in power at the antenna interface, a ratio
                        % SigPowerNormFactor is applied to the variance of the received
                        % signal. Thus, rxSigPower accounts only for the power level of
                        % the signal of interest.
                        % Note that this implementatino assumes that all users have the
                        % same power level as user 1. This is true for all users except
                        % the blocker in this implementation.
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        SigPowerNormFactor = TXGains(1, KIdx, SIRIdx)/(sum(TXGains(1:prm.numUsers,KIdx,SIRIdx)));
                
                    
                        for antIdx = 1:prm.numRx 
                            %%%%%%%%%%%%%%%%%%%%%
                            %LNA (Gain + Noise)%
                            %%%%%%%%%%%%%%%%%%%%%
                    
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %1: Manual Noise Implementation%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            rxSigPower = SigPowerNormFactor*var(rxSigsAnt(antIdx, :, MIdx, KIdx, SIRIdx, AngleIdx));
                            rxNoisePower = rxSigPower / 10^(SNRTherm/10) / 2; 
                            if inp.addThermNoise == 1
                                sigma = sqrt(rxNoisePower);
                            else
                                sigma = 0;
                            end
                            streamReal = RandStream('mt19937ar', 'Seed', antIdx+randNum); % Fixed rng stream for repeatability
                            streamImag = RandStream('mt19937ar', 'Seed', antIdx+MIdx+randNum); % Fixed rng stream for repeatability
                            noiseReal = sigma*randn(streamReal, [1,prm.lengthTxSigsData, 1]);
                            noiseImag = sigma*randn(streamImag, [1,prm.lengthTxSigsData, 1]);
                            noise = noiseReal + 1j*noiseImag;
                            rxSigLNAOut(antIdx, :, MIdx, KIdx, SIRIdx, SNRThermIdx, AngleIdx) =  ...
                            sqrt(db2pow(prm.rxGain))*(rxSigsAnt(antIdx, :, MIdx, KIdx, SIRIdx,  AngleIdx) + noise);
    
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %Variable Gain Amplifier (VGA / AGC):    %
                            %Ideal VGA normalizes constellation power%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            rxSigVGAIn = rxSigLNAOut(antIdx, :, MIdx, KIdx, SIRIdx, SNRThermIdx, AngleIdx);
                            if prm.numRx == 1
                                max_or_mean = "max";
                            else
                                max_or_mean = "mean";
                            end
                            rxSigVGAOut(antIdx, :, MIdx, KIdx, SIRIdx, SNRThermIdx, AngleIdx) = const_normalize(rxSigVGAIn, inp.qam_M, max_or_mean);
                        end
                    
                    
                        for BIdx = 1:length(inp.BSweep)
                            %%%%%%%%%%%%%%%%
                            %ADC Parameters%
                            %%%%%%%%%%%%%%%%
                            prm.ADC_FS = 2; % 1V peak-to-peak (differential)
                            prm.B = inp.BSweep(BIdx);
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %Analog to Digital Conversion%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            rxSigADCIn = rxSigVGAOut(1:prm.numRx, :, MIdx, KIdx, SIRIdx, SNRThermIdx, AngleIdx);
                            rxSigADCOut(1:prm.numRx, :, MIdx, KIdx, BIdx, SIRIdx, SNRThermIdx, AngleIdx) = IQADC(rxSigADCIn, prm.B, prm.ADC_FS);
                        
                            rxSigDBFIn = rxSigADCOut(1:prm.numRx, :, MIdx, KIdx, BIdx, SIRIdx, SNRThermIdx, AngleIdx);
                            if inp.ZF == 1
                                rxSigsCombDBF(1:prm.numUsers,:, MIdx, KIdx, BIdx, SIRIdx, SNRThermIdx, AngleIdx) = GrxZF*rxSigDBFIn;
                            else
                                rxSigsCombDBF(1:prm.numUsers,:, MIdx, KIdx, BIdx, SIRIdx, SNRThermIdx, AngleIdx) = GrxConj*rxSigDBFIn;
                            end
                            
                            for uIdx = 1:prm.numUsers
                                rxSigsCombDBFNorm(uIdx,:, MIdx, KIdx, BIdx, SIRIdx, SNRThermIdx, AngleIdx) = ... 
                                   const_normalize(rxSigsCombDBF(uIdx,:, MIdx, KIdx, BIdx, SIRIdx, SNRThermIdx, AngleIdx), inp.qam_M, "mean");  

                                rxSigsCombDBFDemod(uIdx,:, MIdx, KIdx, BIdx, SIRIdx, SNRThermIdx, AngleIdx) = ... 
                                    qamdemod(rxSigsCombDBFNorm(uIdx,:, MIdx, KIdx, BIdx, SIRIdx, SNRThermIdx, AngleIdx).', ... 
                                    inp.qam_M, OutputType = "bit", UnitAveragePower = true);
                                dataOut = rxSigsCombDBFDemod(uIdx,:, MIdx, KIdx, BIdx, SIRIdx, SNRThermIdx, AngleIdx);

                                ERR = comm.ErrorRate();
                                errStats = ERR(txData(1:length(dataOut), uIdx, KIdx, SIRIdx), dataOut.');
                                BERs(uIdx, MIdx, KIdx, BIdx, SIRIdx, SNRThermIdx, AngleIdx) = errStats(1);
                
                                EVMs(uIdx, MIdx, KIdx, BIdx, SIRIdx, SNRThermIdx, AngleIdx) = ... 
                                   evm(txQamData(:, uIdx, KIdx, SIRIdx),rxSigsCombDBFNorm(uIdx,:, MIdx, KIdx, BIdx, SIRIdx, SNRThermIdx, AngleIdx).');
                                SNDRsMeasured(uIdx, MIdx, KIdx, BIdx, SIRIdx, SNRThermIdx, AngleIdx) = ...
                                    MeasSNDR(rxSigsCombDBFNorm(uIdx,:, MIdx, KIdx, BIdx, SIRIdx, SNRThermIdx, AngleIdx),txQamData(:, uIdx, KIdx, SIRIdx).');
                                if SIRIdx == length(inp.SBRsdBSweep)
                                    SBRminsdB(uIdx,MIdx, KIdx, BIdx, SNRThermIdx, AngleIdx) =  ... 
                                        MeasSBRmin(squeeze(SNDRsMeasured(uIdx, MIdx, KIdx, BIdx, :, SNRThermIdx, AngleIdx)), inp.SBRsdBSweep);
                                end
                                ArrayGainMeasured(uIdx, MIdx, KIdx, BIdx, SIRIdx, SNRThermIdx, AngleIdx) = ...
                                    SNDRsMeasured(uIdx, MIdx, KIdx, BIdx, SIRIdx, SNRThermIdx, AngleIdx) - SNRTherm;
                            end   
                        end
                    end
                end
            end
        end
    end
    ENOBs = (SNDRsMeasured - 4.36)/6.02;
end

%%

function [SBRmindB] = MeasSBRmin(SNRsMeasured, SBRsdB)
    ENOB = (SNRsMeasured - 4.36)/6.02;
    ENOBpolyfit = polyfit(SBRsdB, ENOB, 10);
    ENOBfit = polyval(ENOBpolyfit, SBRsdB);
    [~, idx] = min(abs(ENOBfit - 2));
    SBRmindB = SBRsdB(idx);
end


function [SNDR] = MeasSNDR(qam_data_noisy_norm_in, qam_data_norm_in) 
    qam_data_noisy_norm = qam_data_noisy_norm_in / sqrt(mean(abs(qam_data_noisy_norm_in).^2));
    qam_data_norm = qam_data_norm_in / sqrt(mean(abs(qam_data_norm_in).^2));
    Ptot = var(qam_data_noisy_norm);

    % Estimate signal power from the autocorrelation
    [crossCorr, lags] = xcorr(qam_data_norm - mean(qam_data_norm), qam_data_noisy_norm - mean(qam_data_noisy_norm), "coeff");
    [maxCorr, idx] = max(abs(crossCorr));
    maxLag = lags(idx);
    C = maxCorr;
    
    estimated_signal_power = abs(C)^2*Ptot;
    estimated_noise_power = var(qam_data_noisy_norm - abs(C)*qam_data_norm);
    % Estimate SNR
    SNDR = 10 * log10(estimated_signal_power / estimated_noise_power);
end



function [Dout] = IQADC(Ain, B, ADC_FS)
    %%%%%%%%%%%%%%%%%%
    %1: Mid-Tread ADC%
    %%%%%%%%%%%%%%%%%%
    Ain_I = real(Ain);
    Ain_Q = imag(Ain);

    LSB = ADC_FS/2^B;
    Dout_I = round(Ain_I/LSB)*LSB;
    Dout_Q= round(Ain_Q/LSB)*LSB;

    Dout = Dout_I + 1j*Dout_Q;
end


function [const_out] = const_normalize(const, qam_M, max_or_mean)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %QAM Constellation Amplitude Normalization %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Determine the normalization factor that maps a constellation average 
    %to the constellation's maximum amplitudes. 

    x = (0:qam_M-1)';
    y = qammod(x,qam_M, "UnitAveragePower", true);
    
    if max_or_mean == "mean"
        const_flatten = const(:);
        nonzero_const = const(abs(const_flatten) ~= 0);
        const_norm_factor = mean(abs(y).^2) ./ mean(abs(nonzero_const).^2, 2) ; 
        const_out = const.*sqrt(const_norm_factor);
    elseif max_or_mean == "max"
        const_norm_factor = 2 ./ max(abs(const).^2) ; 
        const_out = const.*sqrt(const_norm_factor);
    end
end


function setLogAxes(logX, logY, logZ)
    grid on;
    grid minor;
    if logX == 1
        xscale log;
    else
        xscale linear;
    end
    if logY == 1
        yscale log;
    else
        yscale linear;
    end

    if logZ == 1
        zscale log;
    else
        zscale linear;
    end
end


function startuplocal
set(groot, 'Default', struct())        %back to factory settings
set(groot, 'DefaultLineLineWidth', 2.5, ...
           'DefaultLineMarkerSize', 18, ...
           'DefaultTextInterpreter', 'LaTeX', ...
           'DefaultAxesTickLabelInterpreter', 'LaTeX', ...
           'DefaultAxesFontName', 'LaTeX', ...
           'DefaultLegendInterpreter', 'LaTeX', ...
           'DefaultAxesLineWidth', 1.5, ...
           'DefaultAxesFontSize', 24, ...
           'DefaultAxesBox', 'on', ...
           'DefaultAxesColor', [1, 1, 1], ...
           'DefaultFigureColor', [1, 1, 1], ...
           'DefaultFigureInvertHardcopy', 'off', ...
           'DefaultFigurePaperUnits', 'inches', ...
           'DefaultFigureUnits', 'pixels');

colors = [
    0 0 0;
    0 0 255;
    255 0 255;
    0 255 255;
    0 255 0;
    255 0 0;
    255 255 0;
    129 52 190]/255;
set(groot, 'DefaultAxesColorOrder', colors);
set(groot, 'defaultFigureRenderer', 'painters')

format shorteng

end