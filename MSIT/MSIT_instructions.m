

 instructions = {'You will see sets of 3 numbers appear\n\n in the center of the screen every few seconds.', ...
     'The numbers will range from 0-3.', ...
     'One of these numbers will be different than the other two.\n\n\n Your task is to press the button corresponding to the identity \n\nof the number that is different.', ...
     'For example, if you see:\n\n100\n\nPress button 1', ...
     'If you see:\n\n020\n\nPress button 2', ...
     'If you see:\n\n030\n\nPress button 3', ...
     'If you see:\n\n212\n\nPress button 1', ...
     'If you see:\n\n112\n\nPress button 2', ...
     'If you see:\n\n322\n\nPress button 3', ...
     'If you see:\n\n221\n\nPress button 1', ...
     'If you see:\n\n211\n\nPress button 2', ...
     'If you see:\n\n232\n\nPress button 3', ...
     'Each set of 3 numbers will be separated by a dot on the screen\n\n lasting approximately 2 seconds.\n\n\nRespond to each set of 3 numbers as quickly as possible,\n\n while still trying to make the correct response.', ...
     'You must make your response within a given time window.\n\nIf your response is too slow,\n\n you will get a warning message before the next dot.', ...
     };

PsychDefaultSetup(2);
    % Get the screen numbers
    screens = Screen('Screens');

    % Draw to the external screen if avaliable
    screenNumber = max(screens);

    % Define black and white
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);

    % Open an on screen window
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

    % Get the size of the on screen window
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);

    % Get the centre coordinate of the window
    [xCenter, yCenter] = RectCenter(windowRect);

    % Query the frame duration
    ifi = Screen('GetFlipInterval', window);

for i = 1:numel(instructions)
    WaitSecs(0.5)
 Screen('TextFont', window, 'Ariel');
   
    
     topPriorityLevel = MaxPriority(window);
     
     
     Priority(topPriorityLevel);
    vbl = Screen('Flip', window);
    Screen('TextSize', window, 50);

  
     DrawFormattedText(window,instructions{i}, 'center', 'center', white);
           
vbl = Screen('Flip', window);
  KbWait

end        
sca
           
            