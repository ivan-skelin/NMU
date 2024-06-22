AssertOpenGL;

%% defining the TTL codes
ttl_mode = 'no'; %'cpod'
COM_label = 'COM4'; 

TTL_Unpleasant_start = 1;
TTL_QuestionOnset = 2;
TTL_ButtonPress = 3;
TTL_Unpleasant_end = 4;

ttl_flag = 1;
       
if ttl_flag == 1
    openTTL_cpod(COM_label);
end

if ttl_flag == 1
    sendTTL_cpod(TTL_Unpleasant_start);
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

% Define colors
black = BlackIndex(window);

% Set up text properties for the question
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, 90);  % Larger font size for the question
Screen('TextStyle', window, 1);

% Set up text properties for numbers
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, 50);  % Standard font size for numbers
Screen('TextStyle', window, 0);

% Define the base rectangle for the scale
rectYpos = windowRect(4) * 0.6;
numWidth = 50; % Width of each clickable area for numbers
numHeight = 50; % Height of each clickable area for numbers

% Define number positions and clickable areas
numbers = 0:10;
numPositions = linspace(windowRect(3) * 0.2, windowRect(3) * 0.8, numel(numbers));
clickableAreas = zeros(numel(numbers), 4);

% Define areas for each number
for i = 1:numel(numbers)
    clickableAreas(i, :) = CenterRectOnPointd([0 0 numWidth numHeight], numPositions(i), rectYpos);
end

% Define and position the Close button
closeButton = CenterRectOnPointd([0 0 100 50], windowRect(3) * 0.9, windowRect(4) * 0.9);
closeButtonText = 'Next';

% File for saving responses
filename = 'Pain_Unpl_Assessment.txt';
fileID = fopen(filename, 'a');

% Display question and record responses
sendTTL_cpod(TTL_QuestionOnset);

% Draw everything once at the start
Screen('FillRect', window, white); % Clear screen
DrawFormattedText(window, 'How unpleasant is your pain right now?', 'center', windowRect(4) * 0.3, black);

for i = 1:numel(numbers)
    numRect = clickableAreas(i, :);
    Screen('FrameRect', window, black, numRect, 2); % Draw number box
    DrawFormattedText(window, num2str(numbers(i)), 'center', 'center', black, [], [], [], [], [], numRect);
end

% Draw labels below the scale
labelOffset = 80; % Distance below the number boxes to place the labels
labelYpos = rectYpos + numHeight / 2 + labelOffset; % Adjust the y position to place labels below the boxes

% Adjust horizontal position for 'Not at all' text
noPainPosition = numPositions(1) - numWidth / 2 - 50;  % 50 pixels to the left of the first number box
DrawFormattedText(window, 'Not at all', noPainPosition, labelYpos, black, [], [], [], [], [], []);
DrawFormattedText(window, 'Unbearable', numPositions(end), labelYpos, black, [], [], [], [], [], []);

% Draw the Close button
Screen('FillRect', window, [0.8 0.2 0.2], closeButton);  % Red close button
DrawFormattedText(window, closeButtonText, 'center', 'center', white, [], [], [], [], [], closeButton);

% Flip to the screen once initially
Screen('Flip', window);

% Initialize responses and timestamps
responses = [];
timestamps = [];

% Wait for mouse click on a box
validClick = false;
while ~validClick
    [x, y, buttons] = GetMouse(window);
    if any(buttons)
        if ttl_flag == 1
            sendTTL_cpod(TTL_ButtonPress);
        end
        if IsInRect(x, y, closeButton)
            break;  % Exit the loop if Close button is clicked
        end

        for i = 1:numel(numbers)
            if IsInRect(x, y, clickableAreas(i, :))
                validClick = true;
                sendTTL_cpod(TTL_ButtonPress);
                selectedNumber = numbers(i);
                % Save the result with a timestamp
                timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
                fprintf(fileID, '%s: %d\n', timestamp, selectedNumber);
                disp(['Pain level recorded: ' num2str(selectedNumber) ' at ' timestamp]);
                responses(end+1) = selectedNumber; % Add response to the array
                timestamps{end+1} = timestamp; % Add timestamp to the array

                lastAnswerTime = GetSecs;  % Reset the timer after an answer
                WaitSecs(0.5);  % Prevent multiple detections of the same click
                break;
            end
        end
    end

    % Check for keyboard input to exit (press ESC to close)
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown
        if keyCode(KbName('ESCAPE'))
            break;
        end
    end
end

% Ensure responses and timestamps have at least one entry
if isempty(responses)
    responses = NaN; % Default value if no response
    timestamps = {datestr(now, 'yyyy-mm-dd HH:MM:SS')}; % Default timestamp
end

% Create the results table for this script
QuestionNum = (1:length(responses))';  % Convert to column vector
QuestionText = repmat({'Unpleasantness level'}, length(responses), 1);  % Cell array of questions
ResponseValues = double(responses)';  % Ensure responses are stored as double
TimestampValues = string(timestamps)';  % Convert timestamps to string array

% Create the table
T = table(QuestionNum, QuestionText, ResponseValues, TimestampValues, ...
          'VariableNames', {'QuestionNumber', 'Question', 'Response', 'Timestamp'});

% Append results to the common results table
global commonResults;
commonResults = [commonResults; T];

% Save individual results to a CSV file
curr_time = datetime('now');
formattedTime = datestr(curr_time, 'HH:MM:SS');
title = convertCharsToStrings(sprintf('ExperimentResultsUnpleasant_%s.csv',formattedTime));
title = strrep(title, ':', '-');
writetable(T, title);

% Clean up and close
if ttl_flag == 1
    sendTTL_cpod(TTL_Unpleasant_end);
    closeTTL_cpod(COM_label);
end
% Close file and screen
fclose(fileID);
sca;
