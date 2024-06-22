



band_of_interest = [4:30];

   [succeeded, timeStampArray, eventIDArray, ttlValueArray, eventStringArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewEventData('Events');
    stim_onset_ttl_ts = timeStampArray(max(find(ttlValueArray==11)));%figure out what TTL value for stim start
   % stim_end_ttl_ts = timeStampArray(find(ttlValueArray==17));%figure out what TTL value for stim end

      stim_onset_ts_ms = int64(round(stim_onset_ttl_ts/1000)); 
    % stim_end_ts_ms = int64(round(stim_end_ttl_ts/1000));

    fill_the_ts_gap;%gets the data for the channels of interest and fills in the timestamp gaps
    
     


    for ch_count = 1:numel(dataArray_all_ch)
  figure;
curr_dataArray = dataArray_all_ch{ch_count};
curr_timeStampArrayFilled = timeStampArrayFilled_ms{ch_count};


fs=1000;
        spect_onset_all = [];
        spect_offset_all = [];
        raw_onset_all = [];
        raw_onset_all = [];

       [wFreq, spect_win_onset_avg, spect_win_offset_avg, raw_win_onset_avg, raw_win_offset_avg] = get_stim_locked(curr_dataArray, curr_timeStampArrayFilled, stim_onset_ts_ms, fs, band_of_interest);

  
     
     
     subplot(2,2,1)%get the correct index for plot
     %imagesc(flipud(zscore(spect_win_onset_avg,[],2)));
       imagesc(flipud(zscore(spect_win_onset_avg,[],2)));xline(900,'w--','LineWidth',3);
       xticks([1 900]); xlabel('time (ms)')
       xticklabels({'-900','0'});
       yticklabels({num2str(band_of_interest(end)),num2str(band_of_interest(1))});
       yticks([1 numel(wFreq)]); ylabel('freq (hz)')
      title(sprintf('%s %s onset',dataBuffer.channelNames{ch_count}, 'CCEP 30hz'));


     subplot(2,2,2)
     imagesc(flipud(zscore(spect_win_offset_avg,[],2)));xline(200,'w--','LineWidth',3)
        xticks([200 700]); xlabel('time (ms)')
       xticklabels({'0','500'});
       yticklabels({num2str(band_of_interest(end)),num2str(band_of_interest(1))});
       yticks([1 numel(wFreq)]); ylabel('freq (hz)')
         title(sprintf('%s %s offset',dataBuffer.channelNames{ch_count}, 'CCEP 30hz'));

         subplot(2,2,3)
     plot(raw_win_onset_avg,'LineWidth',2);xline(900,'r--','LineWidth',3)
        xlim([1 numel(raw_win_onset_avg)]);
        xticks([1 900]); %xlabel('time (ms)')
       xticklabels({'-900','0'});
       % yticklabels({num2str(band_of_interest(end)),num2str(band_of_interest(1))});
       % yticks([1 numel(wFreq)]); 
       ylabel('voltage')
         %title(sprintf('%s %s onset',dataBuffer.channelNames{ch_count+1}, 'CCEP 100hz'));

         subplot(2,2,4)
      plot(raw_win_offset_avg,'LineWidth',2);xline(200,'r--','LineWidth',3)
        xlim([1 numel(raw_win_offset_avg)]);
        xticks([200 700]); %xlabel('time (ms)')
       xticklabels({'0','500'});
       % yticklabels({num2str(band_of_interest(end)),num2str(band_of_interest(1))});
       % yticks([1 numel(wFreq)]); 
       ylabel('voltage')

    end