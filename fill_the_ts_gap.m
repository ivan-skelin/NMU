

        ch_count=1;
        for n_ch_lfp = 1:(numel(dataBuffer.channelNames)-1)

            tic
            [succeeded,dataArray, timeStampArray, channelNumberArray, samplingFreqArray, numValidSamplesArray, numRecordsReturned, numRecordsDropped ] = NlxGetNewCSCData(dataBuffer.channelNames{n_ch_lfp});

            if (~succeeded)
                warning(['Unable to update buffer for channel: ' dataBuffer.channelNames{n_ch_lfp}]);
            end

            if(numRecordsReturned == 0)
                warning(['No Records returned for ' dataBuffer.channelNames{n_ch_lfp}]);
                continue;
            end%


            dataArray_all_ch{ch_count} = double(dataArray);
            timeStampArray = double(timeStampArray);

            if (length(unique(samplingFreqArray))>1)

                warning(['Sampling Frequency for the following channel changed between updates: ' dataBuffer.channelNames{n_ch_lfp}]);
                continue;
            end
            samplingFreq = samplingFreqArray(1);
            %timeStampArrayFilled{ch_count} = int64(createTimeVectorFromRecordTimestamps(timeStampArray, double(samplingFreq)));
            timeStampArrayFilled_ms{ch_count} = int64(round(createTimeVectorFromRecordTimestamps(timeStampArray, double(samplingFreq))./1000));

            ch_count=ch_count+1;


            toc
        end