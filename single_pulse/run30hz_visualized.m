%% 50 Hz Stimulation

% cerestim.beginSequence();
% cerestim.autoStim(1, 2);
% cerestim.wait(900);
% cerestim.endSequence();
% 
% cerestim.play(30);
% pause(30+30)

%for 2 channels

cerestim.beginSequence();
cerestim.beginGroup()
cerestim.autoStim(1, 5);
cerestim.autoStim(2, 5);
cerestim.endGroup()
cerestim.wait(900);
cerestim.endSequence();
 

cerestim.play(30);



pause(60+30)
