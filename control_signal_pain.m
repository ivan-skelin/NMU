function [feature_val] = control_signal_pain(dataArray,  timeStampArrayFilled, trl_onset_ts, band_of_interest, fs)

addpath 'C:\Users\Z8 test\Desktop\closed_loop';

trl_onset_ind = min(find(timeStampArrayFilled==trl_onset_ts));

n_wavelets = 7;
[wFreq, tfdata] = mywavelet(dataArray, fs, n_wavelets, [band_of_interest(1):band_of_interest(2)]);

feature_val = mean(mean(abs(tfdata(:,(trl_onset_ind):(trl_onset_ind + fs*2)))));
