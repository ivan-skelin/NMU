function run_SF_MPQ_with_stim(stim_dur)

%TTLs are picked up by the Nlx computer (the script runStimWithQ.m has to
%be running simultaneously)
%Ivan Skelin, June 2024

%% defining which epochs to stimulate
% stim_option = zeros(1,10);
% a = randperm(10);
% stim_option(a(1:2:end))=1;
stim_option = zeros(1,5);
% stim_option(2)=1;

%% defining the TTL codes


ttl_mode = 'no'; %'cpod'
COM_label = 'COM4';

TTL_stim_start = 10;
TTL_stim_end = 20;


%openTTL_cpod(COM_label);


for x = 1:3
    
    if stim_option(x)==1
        openTTL_cpod(COM_label);
        sendTTL_cpod(TTL_stim_start);
        pause(stim_dur);
        %sendTTL_cpod(TTL_stim_end);
        closeTTL_cpod(COM_label);
    else
        
        pause(stim_dur);
        
    end
    
    %
    % PsychDefaultSetup(2);
    % Screen('Preference', 'SkipSyncTests', 1);
    
    
    Unpleasant;
end
% 
% if ttl_flag == 1
%     
%    closeTTL_cpod(COM_label);
% end

a = datetime;
b = char(a);
c = [b(1:11) '_' b(13:14) b(16:17) b(19:20)];
save(sprintf('stim_option_%s',c),'stim_option');
sca;
clear all;clc;
end




