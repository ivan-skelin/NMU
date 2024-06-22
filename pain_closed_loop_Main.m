
%% need to adapt
succeeded = NlxConnectToServer('localhost')
% this = nlxContinuousDataBuffer('RPHC2', 2000, 2000)
% 
% succeeded = NlxSetApplicationName('pain_closed_loop.m')
% 
% [succeeded, DAS_object, DAS_types] = NlxGetDASObjectsAndTypes();
% 
% %should start the buffer based on the specific TTL received from the task
% %computer, indicating the start of the task
% 
% 
% dataBuffer = nlxContinuousDataBuffer(ChannelsOfInterest, expParams.dataBufferDuration, expParams.bufferFs);
% 
% dataBuffer.bandOfInterest = expParams.testingBandOfInterest;

%%
addpath 'C:\Users\Z8 test\Desktop\closed_loop\CereLAB-master\CereLAB-master';
addpath 'C:\Users\Z8 test\Downloads\Vandana_NFB task\NFB4Memory task coding';

load params_stim;
load trials_stim;
load MSIT_trials;

cerestim = BStimulator();
connx = connect(cerestim);

amp1 = params_stim.amp1;
amp2 = params_stim.amp2;
freq = params_stim.freq;
stim_dur = params_stim.stim_dur;
width1 = params_stim.width1;
width2 = params_stim.width2;
interphase = params_stim.interphase;
waveform_ID = 1;

n_of_pulses = freq*stim_dur;
stimPattern = [n_of_pulses, amp1, amp2, width1, width2, freq, interphase];
polarity = 'AF';
res = configureStimulusPattern(cerestim, waveform_ID, polarity, n_of_pulses, amp1, amp2, width1, width2, freq, interphase);

dataArray_all_ch = [];
experimentON = 1;
curr_trl = 0;
%set the cerestim to trigger mode here. 


while experimentON == 1

    [succeeded, timeStampArray, eventIDArray, ttlValueArray, eventStringArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewEventData('Events');
    trl_onset_ttl_ind = find(ttlValueArray==3);
    if isempty(trl_onset_ttl_ind)==0

        curr_trl_features = [];
        trl_onset_ts_ms = int64(round(timeStampArray(trl_onset_ttl_ind)/1000)); %when it gets the trial onset TTL, it should wait for 3 sec and get the neural data
        pause(3)
        ch_count=1;
        for n_ch_lfp = 2:numel(channelNames)

            tic
            [succeeded,dataArray, timeStampArray, channelNumberArray, samplingFreqArray, numValidSamplesArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewCSCData(channelNames{n_ch_lfp});

            if (~succeeded)
                warning(['Unable to update buffer for channel: ' channelNames{n_ch_lfp}]);
            end

            if(numRecordsReturned == 0)
                warning(['No Records returned for ' channelNames{n_ch_lfp}]);
                continue;
            end%


            dataArray_all_ch{ch_count} = double(dataArray);
            timeStampArray = double(timeStampArray);

            if (length(unique(samplingFreqArray))>1)

                warning(['Sampling Frequency for the following channel changed between updates: ' this.channelNames{n_ch_lfp}]);
                continue;
            end
            samplingFreq = samplingFreqArray(1);
            %timeStampArrayFilled{ch_count} = int64(createTimeVectorFromRecordTimestamps(timeStampArray, double(samplingFreq)));
            timeStampArrayFilled{ch_count} = int64(round(createTimeVectorFromRecordTimestamps(timeStampArray, double(samplingFreq))./1000));

            ch_count=ch_count+1;


            toc
        end

        %control_signal here

        for n_ch = 1:numel(dataArray_all_ch)
            tic
            band_of_interest=[3 8];
            [feature_val]  = control_signal_pain(dataArray_all_ch{n_ch},  timeStampArrayFilled{n_ch}, trl_onset_ts(end), band_of_interest, fs);

            curr_trl_features(n_ch) = feature_val;
            toc
        end
        curr_trl = curr_trl+1;
        % if sum(curr_trl_features < thr_features)>0
        if curr_trl==2
            ch=1;
            cerestim.beginningOfSequence();
            cerestim.autoStimulus(ch, waveform_ID);
            cerestim.endOfSequence();

            [~, curr_ts] = NlxSendCommand(['-GetTimestamp ']);
             curr_ts_ms = round(double(str2num(curr_ts{1}))/1000);

            curr_trl_ITI_dur_ms = (1.75 + ITI_duration{curr_trl})*1000;%adjust for the fact that the button might be pressed earlier than 1.75 sec
            curr_time_left_sec = (curr_trl_ITI_dur_ms - (double(curr_ts_ms) - double(trl_onset_ts_ms)))/1000;
            pause(curr_time_left_sec);
            cerestim.play(1);
            eventString = 'StimSent'; eventID = 11;
             [succeeded, ~] = NlxSendCommand(['-PostEvent "' char(eventString) '" ' int2str(eventID) ' 11']);
           
            cerestim.wait(1000);

            %
            %             % here put the feature vector comparison with thershold and stim trigger, if the conditions for closed loop stim are met;
          
        end
    elseif isempty(find(ttlValueArray==5))==0 %if it identifies the TTL signalling the end of experiment
        experimentON = 0;
    end
end

disconnect(cerestim);
delete(cerestim);

