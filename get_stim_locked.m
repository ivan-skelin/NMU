function [wFreq, spect_win_onset_avg, spect_win_offset_avg, raw_win_onset_avg, raw_win_offset_avg] = get_stim_locked(curr_dataArray, curr_timeStampArrayFilled, stim_onset_ts_ms, fs, band_of_interest)

addpath 'C:\Users\Z8 test\Desktop\closed_loop';
stim_onset_ind=[];
stim_onset_ind = min(find(curr_timeStampArrayFilled==stim_onset_ts_ms));
%stim_offset_ind = min(find(curr_timeStampArrayFilled==stim_end_ts_ms));

curr_data_win = curr_dataArray((stim_onset_ind-fs*2):(stim_onset_ind+fs*65));
n_wavelets = 7;
[wFreq, spect_all] = mywavelet(curr_dataArray((stim_onset_ind-fs*2):(stim_onset_ind+fs*65)), fs, n_wavelets, [band_of_interest(1):band_of_interest(end)]);
%[wFreq, spect_offset] = mywavelet(dataArray((stim_offset_ind-fs*2):(stim_offset_ind+fs*2)), fs, n_wavelets, [band_of_interest(1):band_of_interest(2)]);

spect_win_onset = [];
raw_win_onset = [];
start_ind = 1100; end_ind = 2100;%from -900 till 100 ms, relative to stim onset
for i = 1:30

    spect_win_onset(:,:,i) = abs(spect_all(:,start_ind:end_ind));
    raw_win_onset(i,:) = curr_data_win(start_ind:end_ind);
    start_ind = start_ind + 1900;
    end_ind = end_ind + 1900;

end
spect_win_onset_avg = mean(spect_win_onset,3);
raw_win_onset_avg = mean(raw_win_onset);
spect_win_onset = [];
raw_win_onset = [];

spect_win_offset = [];
raw_win_offset = [];
start_ind = 2800; end_ind = 3900; %from -200 till 900 following the stim offset
for i = 1:30

    spect_win_offset(:,:,i) = abs(spect_all(:,start_ind:end_ind));
    raw_win_offset(i,:) = curr_data_win(start_ind:end_ind);
    start_ind = start_ind + 1900;
    end_ind = end_ind + 1900;

end

spect_win_offset_avg = mean(spect_win_offset,3);
raw_win_offset_avg = mean(raw_win_offset);
spect_win_offset = [];
raw_win_offset = [];


end
