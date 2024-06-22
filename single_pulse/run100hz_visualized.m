%% 100 Hz Stimulation

% cerestim.beginSequence();
% cerestim.autoStim(1, 3);
% cerestim.wait(900);
% cerestim.endSequence();
% 
% cerestim.play(30);
% pause(30+30)

%for 2 channels

cerestim.beginSequence();
cerestim.beginGroup()
cerestim.autoStim(1, 3);
cerestim.autoStim(2, 3);
cerestim.endGroup()
cerestim.wait(900);
cerestim.endSequence();
  eventString = 'StimSent100hz'; eventID = 11;
    [succeeded, ~] = NlxSendCommand(['-PostEvent "' char(eventString) '" ' int2str(eventID) ' 11']);

cerestim.play(30);
 eventString = 'StimEnd100hz'; eventID = 17;
    [succeeded, ~] = NlxSendCommand(['-PostEvent "' char(eventString) '" ' int2str(eventID) ' 11']);


band_of_interest = [4:30];

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

  
     
     subplot(numel(dataArray_all_ch),2,(ch_count*2)-1)%get the correct index for plot
     %imagesc(flipud(zscore(spect_win_onset_avg,[],2)));
       imagesc(flipud(spect_win_onset_avg));xline(900,'w--','LineWidth',3);
       xticks([1 900]); xlabel('time (ms)')
       xticklabels({'-900','0'});
       yticklabels({num2str(band_of_interest(end)),num2str(band_of_interest(1))});
       yticks([1 numel(wFreq)]); ylabel('freq (hz)')
      title(sprintf('%s %s onset',dataBuffer.channelNames{ch_count+1}, 'CCEP 100hz'));


     subplot(numel(dataArray_all_ch),2,(ch_count*2))
     imagesc(flipud(spect_win_offset_avg));xline(200,'w--','LineWidth',3)
        xticks([200 700]); xlabel('time (ms)')
       xticklabels({'0','500'});
       yticklabels({num2str(band_of_interest(end)),num2str(band_of_interest(1))});
       yticks([1 numel(wFreq)]); ylabel('freq (hz)')
         title(sprintf('%s %s offset',dataBuffer.channelNames{ch_count+1}, 'CCEP 100hz'));

         subplot(numel(dataArray_all_ch),2,(ch_count*2)+1)
     plot(raw_win_onset_avg,LineWidth',2);xline(900,'r--','LineWidth',3)
        xticks([1 900]); %xlabel('time (ms)')
       xticklabels({'-900','0'});
       % yticklabels({num2str(band_of_interest(end)),num2str(band_of_interest(1))});
       % yticks([1 numel(wFreq)]); 
       ylabel('voltage')
         %title(sprintf('%s %s onset',dataBuffer.channelNames{ch_count+1}, 'CCEP 100hz'));

         subplot(numel(dataArray_all_ch),2,(ch_count*2)+2)
      plot(raw_win_offset_avg,LineWidth',2);xline(200,'r--','LineWidth',3)
        xticks([200 700]); %xlabel('time (ms)')
       xticklabels({'0','500'});
       % yticklabels({num2str(band_of_interest(end)),num2str(band_of_interest(1))});
       % yticks([1 numel(wFreq)]); 
       ylabel('voltage')

    end
pause(60+30)
