
clc;clear all;
%% need to adapt
succeeded = NlxConnectToServer('localhost')

load expParams_208.mat;
% this = nlxContinuousDataBuffer('RPHC2', 2000, 2000)
%
% succeeded = NlxSetApplicationName('pain_closed_loop.m')
%
channelNames = [5:7 281];
% dataBuffer.bandOfInterest = expParams.testingBandOfInterest;
%Events channel is number 281 in this montage. other channel names need to
%be added in a cell array called channelNames
[succeeded, DAS_object, DAS_types] = NlxGetDASObjectsAndTypes();
dataBuffer = nlxContinuousDataBuffer(DAS_object(channelNames), expParams.dataBufferDuration, expParams.bufferFs);

%%
addpath 'C:\Users\Z8 test\Desktop\closed_loop\CereLAB-master\CereLAB-master';
addpath 'C:\Users\Z8 test\Downloads\Vandana_NFB task\NFB4Memory task coding';

%load params_stim;

cerestim = cerestim96();
serial = cerestim.scanForDevices()
cerestim.selectDevice(serial(1));
cerestim.connect(0);
% 
% cerestim = BStimulator();
% connx = connect(cerestim);

% n_of_pulses = freq*stim_dur;
% stimPattern = [n_of_pulses, amp1, amp2, width1, width2, freq, interphase];
% polarity = 'AF';
% res = configureStimulusPattern(cerestim, waveform_ID, polarity, n_of_pulses, amp1, amp2, width1, width2, freq, interphase);

dataArray_all_ch = [];
experimentON = 1;
curr_trl = 0;
%set the cerestim to trigger mode here.
%instead of the params below, insert the single pulse stim parameters
% amp1 = params_stim.amp1;
% amp2 = params_stim.amp2;
% stim_dur = params_stim.stim_dur;
% width1 = params_stim.width1;
% width2 = params_stim.width2;
% interphase = params_stim.interphase;
% waveform_ID = 1;
band_of_interest = [4:30];
frequency = 130;
amplitude = 5000; %uA
pulse_width = 60; %uS
curr_stim_config = sprintf('VTA_L12_%dua_%dHz', amplitude, frequency);
% res = configureStimulusPattern(cerestim, waveform_ID, polarity, n_of_pulses, amp1, amp2, width1, width2, freq, interphase);
% res = configureStimulusPattern(cerestim, 1, 'CF', 1, 3000, 0, 300, 0, 1, 0);
%cerestim.setStimPattern(1, 1, 1, 3000, 3000, 150, 150, 53, 999);
cerestim.setStimPattern('waveform',1, 'polarity',1,'pulses',frequency, 'amp1', amplitude, 'amp2', amplitude, 'width1', pulse_width, 'width2', pulse_width, 'interphase', 53, 'frequency', frequency)
 [succeeded, timeStampArray, eventIDArray, ttlValueArray, eventStringArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewEventData('Events');

 figure;
 
 while experimentON == 1

    [succeeded, timeStampArray, eventIDArray, ttlValueArray, eventStringArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewEventData('Events');
    trl_onset_ttl_ind = find(ttlValueArray==10);
    trl_end_ttl_ind = find(ttlValueArray==20);
    if isempty(trl_onset_ttl_ind)==0

        %
        % ch=1;
        % cerestim.beginningOfSequence();
        % cerestim.autoStimulus(ch, waveform_ID);
        % cerestim.endOfSequence();
        % %here should be the single pulse stim loop
        % % cerestim.play(1);
        eventString = sprintf('StimSent_%s', curr_stim_config); eventID = 11;
        [succeeded, ~] = NlxSendCommand(['-PostEvent "' char(eventString) '" ' int2str(eventID) ' 11']);

       cerestim.beginSequence();
        cerestim.beginGroup()
        cerestim.autoStim(1, 1);
        cerestim.autoStim(2, 1);
        cerestim.endGroup()
        %cerestim.wait(900);
        cerestim.endSequence();

        cerestim.play(300);
          eventString = sprintf('StimEnd_%s', curr_stim_config); eventID = 17;
        [succeeded, ~] = NlxSendCommand(['-PostEvent "' char(eventString) '" ' int2str(eventID) ' 11']);
        % pause(30+30)
        % cerestim.wait(1000);

         [succeeded, timeStampArray, eventIDArray, ttlValueArray, eventStringArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewEventData('Events');
    stim_onset_ttl_ts = timeStampArray(find(ttlValueArray==11));%figure out what TTL value for stim start
    stim_end_ttl_ts = timeStampArray(find(ttlValueArray==17));%figure out what TTL value for stim end

      stim_onset_ts_ms = int64(round(stim_onset_ttl_ts/1000)); 
     stim_end_ts_ms = int64(round(stim_end_ttl_ts/1000));

    fill_the_ts_gap;%gets the data for the channels of interest and fills in the timestamp gaps
    
       


    for ch_count = 1:numel(dataArray_all_ch)

curr_dataArray = dataArray_all_ch{ch_count};
curr_timeStampArrayFilled = timeStampArrayFilled_ms{ch_count};


fs=1000;
        spect_onset_all = [];
        spect_offset_all = [];
        raw_onset_all = [];
        raw_onset_all = [];

       [wFreq, spect_win_onset_avg, spect_win_offset_avg, raw_win_onset_avg, raw_win_offset_avg] = get_stim_locked(curr_dataArray, curr_timeStampArrayFilled, stim_onset_ts_ms, stim_end_ts_ms, fs, band_of_interest);

    % spect_onset_all(:,:,n_trials) = spect_onset; 
    %  spect_offset_all(:,:,n_trials) = spect_offset; 
    %  raw_onset_all(n_trials,:) = raw_onset;
    %   raw_offset_all(n_trials,:) = raw_offset;

    % if ndims(spect_onset_all)>2
    %     curr_spect_onset_avg = mean(spect_onset_all,3);
    %     curr_spect_offset_avg = mean(spect_offset_all,3);
    %     curr_raw_onset_avg = mean(raw_onset_all,2);
    %    curr_raw_offset_avg = mean(raw_offset_all,2);
    % else
    %     curr_spect_onset_avg = spect_onset;
    %     curr_spect_offset_avg = spect_offset;
    %      curr_raw_onset_avg = mean(raw_onset_all,2);
    %    curr_raw_offset_avg = mean(raw_offset_all,2);
    % end
     
     subplot(numel(dataArray_all_ch),2,(ch_count*2)-1)%get the correct index for plot
     %imagesc(flipud(zscore(spect_win_onset_avg,[],2)));
       imagesc(flipud(spect_win_onset_avg));xline(900,'w--','LineWidth',3);
       xticks([1 900]); xlabel('time (ms)')
       xticklabels({'-900','0'});
       yticklabels({num2str(band_of_interest(end)),num2str(band_of_interest(1))});
       yticks([1 numel(wFreq)]); ylabel('freq (hz)')
     title(sprintf('%s',dataBuffer.channelNames{ch_count+1}));

     subplot(numel(dataArray_all_ch),2,(ch_count*2))
     imagesc(flipud(spect_win_offset_avg));xline(200,'w--','LineWidth',3)
        xticks([200 700]); xlabel('time (ms)')
       xticklabels({'0','500'});
       yticklabels({num2str(band_of_interest(end)),num2str(band_of_interest(1))});
       yticks([1 numel(wFreq)]); ylabel('freq (hz)')
        title(sprintf('%s',dataBuffer.channelNames{ch_count+1}));
    end

    elseif isempty(trl_end_ttl_ind)==0
             cerestim.stop();
 
    end
end

% if isempty(find(ttlValueArray==20))==0 %if it identifies the TTL signalling the end of experiment
%         experimentON = 0;
% end
disconnect(cerestim);
delete(cerestim);

