
%this comes at the top of the task-running script
% Initialize Psychtoolbox
clear all;clc
load trial_stim;

addpath C:\Users\klab\OneDrive\Desktop\closed_loop\pain\CereLAB-master\CereLAB-master;
ttl_flag = 1;
stim_mode =0;

if stim_mode==1

cerestim = BStimulator();
connx = connect(cerestim);


if connx < 0
    error('Can''t connect to cerestim')
end

end
%% defining the TTL codes
ttl_mode = 'no'; %'cpod'
COM_label = 'COM4'; 

TTL_MSIT_start = 1;
TTL_ITIOnset = 2;
TTL_StimulusOnset = 3;
TTL_ButtonPress = 4;
TTL_MSIT_end = 5;



       
if ttl_flag == 1
openTTL_cpod(COM_label);
end
%%

if ttl_flag == 1
sendTTL_cpod(TTL_MSIT_start);
end


Screen('Preference', 'SkipSyncTests', 1);  % Use with caution, only for testing purposes

% Setup full-screen mode
screenNumber = max(Screen('Screens'));
white = WhiteIndex(screenNumber);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white);

% Define colors and text properties
black = BlackIndex(window);
gray = [190 190 190];  % Light gray for boxes
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, 400);
KbName('UnifyKeyNames')
deviceNumber = -1; 

%%
AssertOpenGL;


Screen('Preference', 'SkipSyncTests', 1);  % Use with caution, only for testing purposes

% Setup full-screen mode
screenNumber = max(Screen('Screens'));
white = WhiteIndex(screenNumber);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white);

% Define colors and text properties
black = BlackIndex(window);
gray = [190 190 190];  % Light gray for boxes
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, 400);
KbName('UnifyKeyNames')
deviceNumber = -1; 

% Initialize Psychtoolbox
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1); % Skip synchronization tests for faster startup

%%
load MSIT_trials;

% Define box dimensions and positions
boxWidth = 400;
boxHeight = 60;
boxYpos = windowRect(4) * 0.7;
spacing = 350;
numOptions=3;
baseXpos = (windowRect(3) - numOptions * boxWidth - (numOptions - 1) * spacing) / 2;

%trials = {'121','122','123'};
trials = sequence;
white = [255 255 255];
activeKeys = ['1','2','3'];

rsp.RT = NaN; rsp.keyCode = []; rsp.keyName = []; rsp.sequence = [];
rsp.duration = []; rsp.epoch = [];
filename = datestr(now);
filename = strrep(filename,' ','_');
filename = strrep(filename,':','-');
logfile = fopen([sprintf('%s',pwd) filename '.txt'], 'a');

if stim_mode==1
    
amp1 = 2000; % in microV
amp2 = 2000; % in microV
freq = 130; %in Hz
stim_dur = 0.6; %in sec
width1 = 90; %in microsec
width2 = 90;
interphase = 53; % in microsec
waveform_ID = 1;

n_of_pulses = round(freq*stim_dur);
stimPattern = [n_of_pulses, amp1, amp2, width1, width2, freq, interphase];% n_of_pulses, amp1, amp2, width1, width2, freq, interphase 
polarity = 'AF'; %polarity - AF = anodal first, CF = cathodal first
%res = configureStimulusPattern(cerestim, waveform_ID, polarity, stimPattern); %configures the stim pattern
res = configureStimulusPattern(cerestim, waveform_ID, polarity, 78, 2000, 2000, 90, 90, 130, 53); 
end
%%
% Main loop
trial_count=1;
for i = 1:64%numel(trials)% Change the number of trials as needed
    % Present stimulus (replace with your own code)
    DrawFormattedText(window, trials{i}, 'center', windowRect(4)/2, black);
    Screen('Flip', window);
    
    

    if strcmp(epoch{i},'ITI')==1
        if ttl_flag == 1
        sendTTL_cpod(TTL_ITIOnset);
        end
      rsp(i).duration = duration{i};
      rsp(i).epoch = epoch{i};
    WaitSecs(duration{i});
    
    else
    
    if ttl_flag == 1
        sendTTL_cpod(TTL_StimulusOnset);
    end
    
    if trial_stim(i)==1 & stim_mode==1
        
        ch=1;
        %stim_trigger(ch, waveform_ID);
        
        cerestim.beginningOfSequence();
% cerestim.beginningOfGroup(); %looks like this is needed only when multiple patterns or locations are used
cerestim.autoStimulus(ch, waveform_ID); %input arguments are the electrode and waveform ID.
%cerestim.autoStimulus(ch2, waveform_ID_2); %input arguments are the electrode and waveform ID.
%Q3: should there be a pair of electrodes?
%Q4: what command do we need here just to run one stim train, as configured
%above?
%  cerestim.endOfGroup();
cerestim.endOfSequence();
%Q5: could the lines 49-56 be defined outside the loop and not repeated in
%each iteration?
cerestim.play(1); %Q6: this seems to be the stim sending command
cerestim.wait(1000); %waiting for 1 sec
       % fprintf(logfile,'%d    %d', i, timestamp_stim_onset, polarity, stim_patterns); %might be a good idea to log in the stim pattern and time
        
    end
% Set the maximum time to wait for a response (in seconds)
maxWaitTime = 4;


t2wait = 4; 
% if the wait for presses is in a loop, 
% then the following two commands should come before the loop starts
% restrict the keys for keyboard input to the keys we want
RestrictKeysForKbCheck(activeKeys);
% suppress echo to the command line for keypresses
ListenChar(2);

tStart = GetSecs;
% repeat until a valid key is pressed or we time out
timedout = false;



while ~timedout
    % check if a key is pressed
    % only keys specified in activeKeys are considered valid
    [ keyIsDown, keyTime, keyCode ] = KbCheck; 
      if(keyIsDown), break; end
      if( (keyTime - tStart) > t2wait), timedout = true; end
  end
  % store code for key pressed and reaction time
  if(~timedout)
      if ttl_flag == 1
       sendTTL_cpod(TTL_ButtonPress);
      end
      trial_count=trial_count+1;
      rsp(i).RT      = keyTime - tStart;
      rsp(i).keyCode = keyCode;
      rsp(i).keyName = KbName(rsp(i).keyCode);
      rsp(i).duration = duration{i};
      rsp(i).epoch = epoch{i};
      rsp(i).sequence = sequence{i};
  end
% if the wait for presses is in a loop, 
% then the following two commands should come after the loop finishes
% reset the keyboard input checking for all keys
RestrictKeysForKbCheck;

end
end

if ttl_flag == 1
        sendTTL_cpod(TTL_MSIT_end);
end

% Save the table to a CSV file
curr_time = datetime('now');
formattedTime = datestr(curr_time, 'HH:MM:SS');

title = convertCharsToStrings(sprintf('MSIT_%s.mat',formattedTime));

title = strrep(title, ':', '-');
save(sprintf('%s',title),'rsp');

% Clean up
Screen('CloseAll');
sca

if stim_mode==1
    
disconnect(cerestim);
delete(cerestim);

end
fclose(logfile);