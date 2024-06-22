%addpath 'C:\Users\Z8 test\Desktop\closed_loop\CereLAB-master\CereLAB-master';
clc;clear all;

addpath 'C:\Users\Z8 test\Desktop\closed_loop\CereStim-API\Binaries';
cerestim = cerestim96();
serial = cerestim.scanForDevices()
cerestim.selectDevice(serial(1));
cerestim.connect(0);

succeeded = NlxConnectToServer('localhost')

load expParams_208.mat;
% this = nlxContinuousDataBuffer('RPHC2', 2000, 2000)
%
% succeeded = NlxSetApplicationName('pain_closed_loop.m')
%

% dataBuffer.bandOfInterest = expParams.testingBandOfInterest;
%Events channel is number 281 in this montage. other channel names need to
%be added in a cell array called channelNames
[succeeded, DAS_object, DAS_types] = NlxGetDASObjectsAndTypes();
channelNames = [2:4 281];
dataBuffer = nlxContinuousDataBuffer(DAS_object(channelNames), expParams.dataBufferDuration, expParams.bufferFs);

%%
addpath 'C:\Users\Z8 test\Desktop\closed_loop\CereLAB-master\CereLAB-master';
addpath 'C:\Users\Z8 test\Downloads\Vandana_NFB task\NFB4Memory task coding';


%% RUN FROM HERE TO START PROTOCOL

%frequency = 100; % must always be greater than 15Hz to use this approach, otherwise see below
amplitude = 2000; %uA
pulse_width = 60; %uS

% setStimPattern(waveformID, polarity, numberOfPulses, amp1, amp2, width1, width2, interphase, frequency) 
% Polarity: 0 = Anodic first phase, 1 = Cathodic first phase  

% Define waveform for 1 Hz stimulation
% Parameters: waveformID, polarity, numberOfPulses, amp1, amp2, width1, width2, interphase, frequency

% res = configureStimulusPattern(cerestim, waveform_ID, polarity, n_of_pulses, amp1, amp2, width1, width2, freq, interphase);
% res = configureStimulu            (1, 1, 1, 3000, 3000, 150, 150, 53, 999);
cerestim.setStimPattern('waveform',1, 'polarity',1,'pulses',1, 'amp1', amplitude, 'amp2', amplitude, 'width1', pulse_width, 'width2', pulse_width, 'interphase', 53, 'frequency', 999)
cerestim.setStimPattern('waveform',5, 'polarity',1,'pulses',30, 'amp1', amplitude, 'amp2', amplitude, 'width1', pulse_width, 'width2', pulse_width, 'interphase', 53, 'frequency', 30)
cerestim.setStimPattern('waveform',2, 'polarity',1,'pulses',50, 'amp1', amplitude, 'amp2', amplitude, 'width1', pulse_width, 'width2', pulse_width, 'interphase', 53, 'frequency', 50)
cerestim.setStimPattern('waveform',3, 'polarity',1,'pulses',100, 'amp1', amplitude, 'amp2', amplitude, 'width1', pulse_width, 'width2', pulse_width, 'interphase', 53, 'frequency', 100)
cerestim.setStimPattern('waveform',4, 'polarity',1,'pulses',140, 'amp1', amplitude, 'amp2', amplitude, 'width1', pulse_width, 'width2', pulse_width, 'interphase', 53, 'frequency', 140)
% Define waveform for 10 Hz stimulation
% cerestim.setStimPattern(2, 1, 1, 3000, 0, 300, 0, 0, 999);
% % Define waveform for 100 Hz stimulation
% cerestim.setStimPattern(3, 1, 1, 3000, 0, 300, 0, 0, 100);
a = datetime;
b=char(a);
c = [b(1:11) '_' b(13:14) b(16:17) b(19:20)];
save(sprintf('stim_parameters_%s',c),'cerestim');
  eventString = 'RACC_LACC7_8'; eventID = 12;
    [succeeded, ~] = NlxSendCommand(['-PostEvent "' char(eventString) '" ' int2str(eventID) ' 11']);

%run1hz;
  [succeeded, ~] = NlxSendCommand(['-PostEvent "' char(eventString) '" ' int2str(eventID) ' 11']);
 eventString = 'StimStart30hz'; eventID = 11;
    [succeeded, ~] = NlxSendCommand(['-PostEvent "' char(eventString) '" ' int2str(eventID) ' 11']);

run30hz_visualized;
 % eventString = 'StimEnd30hz'; eventID = 17;
 %    [succeeded, ~] = NlxSendCommand(['-PostEvent "' char(eventString) '" ' int2str(eventID) ' 11']);
get_the_plots;
%run50hz;

%run100hz;

%run140hz;


% %% 1 Hz Stimulation
% % Begin overall sequence
% cerestim.beginSequence();
% 
% for i = 1:30
%     cerestim.autoStim(1, 1);  % Stimulate electrode 1 with waveform 1
%     cerestim.wait(999.7);     % Wait for the interpulse duration
% end
% cerestim.endSequence();
% 
% cerestim.play(1);
% pause(30+30);

% %% 10 Hz Stimulation
% 
% 
% for i = 1:30
%     cerestim.beginSequence();
%     for j = 1:10
%         cerestim.autoStim(1, 1);  % Stimulate electrode 1 with waveform 2
%         cerestim.wait(99.7);      % Wait for the interpulse duration
%     end
%     %cerestim.wait(900);           % Wait for the remainder of the 1-second period
%     cerestim.endSequence();
% 
%     cerestim.play(1);
%     pause(1.9);              % 5 second pause between settings
% 
% end
% 
% pause(30+30);
% 
% %% 50 Hz Stimulation
% 
% cerestim.beginSequence();
% cerestim.autoStim(1, 2);
% cerestim.wait(900);
% cerestim.endSequence();
% 
% cerestim.play(30);
% pause(30+30)
% 
% %% 100 Hz Stimulation
% 
% cerestim.beginSequence();
% cerestim.autoStim(1, 3);
% cerestim.wait(900);
% cerestim.endSequence();
% 
% cerestim.play(30);
% pause(30+30)
% 
% %% 140 Hz Stimulation
% 
% cerestim.beginSequence();
% cerestim.autoStim(1, 4);
% cerestim.wait(900);
% cerestim.endSequence();
% 
% cerestim.play(30);
% pause(30+30)
