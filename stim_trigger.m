
function stim_trigger(ch, waveform_ID)

cerestim.beginningOfSequence();
% cerestim.beginningOfGroup(); %looks like this is needed only when multiple patterns or locations are used
cerestim.autoStimulus(ch, waveform_ID_1); %input arguments are the electrode and waveform ID.
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
        
        