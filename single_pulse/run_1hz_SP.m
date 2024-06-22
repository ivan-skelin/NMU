
addpath 'C:\Users\Z8 test\Desktop\closed_loop\CereLAB-master\CereLAB-master';
addpath 'C:\Users\Z8 test\Desktop\closed_loop\CereStim-API\Binaries';
succeeded = NlxConnectToServer('localhost');
cerestim = cerestim96();
serial = cerestim.scanForDevices();
cerestim.selectDevice(serial(1));
cerestim.connect(0);

cerestim.setStimPattern('waveform',1, 'polarity',1,'pulses',1, 'amp1', 3000, 'amp2', 3000, 'width1', 150, 'width2', 150, 'interphase', 53, 'frequency', 999)


%% 1 Hz Stimulation
% Begin overall sequence
cerestim.beginSequence();

for i = 1:30

    cerestim.autoStim(1, 1);  % Stimulate electrode 1 with waveform 1
    cerestim.wait(999.7);     % Wait for the interpulse duration
end
cerestim.endSequence();

eventString = 'SP_StimTrainStart_1hz'; eventID = 11;
[succeeded, ~] = NlxSendCommand(['-PostEvent "' char(eventString) '" ' int2str(eventID) ' 11']);
cerestim.play(1);
eventString = 'SP_StimTrainStart_1hz'; eventID = 12;
[succeeded, ~] = NlxSendCommand(['-PostEvent "' char(eventString) '" ' int2str(eventID) ' 11']);
pause(30);