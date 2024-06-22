function run_Q_with_stim(stim_on)
% TTL codes definitions
ttl_mode = 'no'; % 'cpod'
COM_label = 'COM4';
TTL_stim_start = 10;
TTL_stim_end = 20;

% Initialize common results table
global commonResults;
commonResults = table();

if stim_on == 1
    openTTL_cpod(COM_label);
    sendTTL_cpod(TTL_stim_start);
    closeTTL_cpod(COM_label);
end

pause(30);

% Run individual scripts (make sure these scripts append to the commonResults table)
VAS_v3;
SF_MPQ_V2_v2;
PCS_v2;
Unpleasant;
VAS_v3;

if stim_on == 1
    openTTL_cpod(COM_label);
    sendTTL_cpod(TTL_stim_end);
    closeTTL_cpod(COM_label);
end

% Add "stim on/off" status to the common results
if stim_on == 1
    stimStatus = repmat({'Stim On'}, height(commonResults), 1);
else
    stimStatus = repmat({'Stim Off'}, height(commonResults), 1);
end
commonResults.StimStatus = stimStatus;

% Save the combined results table to a CSV file
a = datetime;
formattedTime = datestr(a, 'yyyy-mm-dd_HHMMSS');
filename = sprintf('CombinedResults_%s.csv', formattedTime);
writetable(commonResults, filename);

% Clear screen and window
sca;
end
