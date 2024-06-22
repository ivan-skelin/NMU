% Initialize Psychtoolbox
AssertOpenGL;
Screen('Preference', 'SkipSyncTests', 1);  % Use with caution, only for testing purposes

%% defining the TTL codes
ttl_mode = 'no'; %'cpod'
COM_label = 'COM4'; 

TTL_SF_MPQ_short_start = 1;
TTL_QuestionOnset = 2;
TTL_ButtonPress = 3;
TTL_SF_MPQ_short_end = 4;

ttl_flag = 1;
       
if ttl_flag == 1
    openTTL_cpod(COM_label);
end

if ttl_flag == 1
    sendTTL_cpod(TTL_SF_MPQ_short_start);
end

% Define the size of the window (change values as needed for desired size)
winWidth = 3000;
winHeight = 1800;

% Setup screen in a window mode instead of full screen
screenNumber = max(Screen('Screens'));

% Get the size of the screen
[screenWidth, screenHeight] = Screen('WindowSize', screenNumber);

% Calculate the position to center the window on the screen
winRect = [(screenWidth - winWidth)/2, (screenHeight - winHeight)/2, ...
           (screenWidth + winWidth)/2, (screenHeight + winHeight)/2];

% Open a window with a white background
white = WhiteIndex(screenNumber);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white, winRect);

% Define colors and text properties
black = BlackIndex(window);
gray = [190 190 190];  % Light gray for boxes
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, 40);  % Smaller text size for the questions

% Define your SF-MPQ-2 questions
questions = {
    'Tiring/Exhausting',
    'Sickening',
    'Fearful',
    'Punishing/Cruel',
};

responseOptions = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'};
numOptions = length(responseOptions);
responses = zeros(length(questions), 1);
timestamps = strings(length(questions), 1);

% Define box dimensions and positions
boxWidth = 70;  % Adjusted box width for VAS scale
boxHeight = 50;  % Adjusted box height for VAS scale
boxYpos = windowRect(4) * 0.6;
spacing = 10;  % Adjusted spacing between boxes
baseXpos = (windowRect(3) - numOptions * boxWidth - (numOptions - 1) * spacing) / 2;

% Define and position the Close button
closeButton = CenterRectOnPointd([0 0 100 50], windowRect(3) * 0.9, windowRect(4) * 0.9);
closeButtonText = 'Close/Next';

% Display each question and record responses
for i = 1:length(questions)
    sendTTL_cpod(TTL_QuestionOnset);
    % Clear the screen before drawing the question
    Screen('FillRect', window, white);
    
    DrawFormattedText(window, questions{i}, 'center', windowRect(4) * 0.3, black);
    
    % Display response options and text above
    for j = 1:numOptions
        boxXpos = baseXpos + (j-1) * (boxWidth + spacing);
        boxRect = [boxXpos, boxYpos - 30, boxXpos + boxWidth, boxYpos + boxHeight];
        Screen('FillRect', window, gray, boxRect);  % Fill the box with gray
        Screen('FrameRect', window, black, boxRect, 2);  % Draw a box around the clickable area
        
        % Center the response option text within the box
        DrawFormattedText(window, responseOptions{j}, 'center', 'center', black, [], [], [], [], [], boxRect);
    end
    
    % Add labels 'none' and 'worst possible' at the beginning and end of the scale
    DrawFormattedText(window, 'None', baseXpos - 50, boxYpos + 70, black);
    DrawFormattedText(window, 'Worst possible', baseXpos + (numOptions-1) * (boxWidth + spacing), boxYpos + 70, black);
    
    % Draw the Close button
    Screen('FillRect', window, [0.8 0.2 0.2], closeButton);  % Red close button
    DrawFormattedText(window, closeButtonText, 'center', 'center', white, [], [], [], [], [], closeButton);
    
    Screen('Flip', window);
    
    % Wait for mouse click on a box
    validClick = false;
    while ~validClick
        [x, y, buttons] = GetMouse(window);
        if any(buttons)
            if IsInRect(x, y, closeButton)
                sca;
                return;  % Exit the script if Close button is clicked
            end
            
            for j = 1:numOptions
                boxXpos = baseXpos + (j-1) * (boxWidth + spacing);
                boxRect = [boxXpos, boxYpos - 30, boxXpos + boxWidth, boxYpos + boxHeight];
                if IsInRect(x, y, boxRect)
                    validClick = true;
                    sendTTL_cpod(TTL_ButtonPress);
                    responses(i) = j-1;  % Store response index
                    timestamps(i) = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
                    WaitSecs(0.5);  % Prevent accidental multiple clicks
                    break;
                end
            end
        end
    end

    % Clear the screen before the next question
    Screen('FillRect', window, white);
    Screen('Flip', window);
    WaitSecs(0.5);  % Short delay before the next question
end

% Clean up and close
if ttl_flag == 1
    sendTTL_cpod(TTL_SF_MPQ_short_end);
    closeTTL_cpod(COM_label);
end

% Convert data types
QuestionNum = (1:length(questions))';  % Convert to column vector
QuestionText = questions;  % Cell array of questions
ResponseValues = double(responses);  % Ensure responses are stored as double
TimestampValues = string(timestamps);  % Convert timestamps to string array

% Create the table
T = table(QuestionNum, QuestionText, ResponseValues, TimestampValues, ...
          'VariableNames', {'QuestionNumber', 'Question', 'Response', 'Timestamp'});

% Append results to the common results table
global commonResults;
commonResults = [commonResults; T];   
      
% Save the table to a CSV file
curr_time = datetime('now');
formattedTime = datestr(curr_time, 'HH:MM:SS');
title = convertCharsToStrings(sprintf('ExperimentResultsSF_MPQ_V2_%s.csv',formattedTime));
title = strrep(title, ':', '-');
writetable(T, title);

% Close the window
sca;
