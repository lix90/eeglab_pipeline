function EEG = rej_epoch_by_spectra(EEG, db_thresh, hz_thresh)

fprintf('*************************************\n');
fprintf('Detect bad epochs by abnormal spectra\n');
fprintf('*************************************\n');

if isempty(db_thresh)
    db_thresh = [-35 35];
end

if isempty(hz_thresh)
    hz_thresh = [20 40];
end

ichan = find(pick_channel_types(EEG, {'eeg'}));
if isempty(ichan)
    ichan = 1:EEG.nbchan;
end
[EEG, Irej, ~] = pop_rejspec(EEG, 1, ...
                             'elecrange', ichan, ...
                             'threshold', db_thresh, ...
                             'freqlimits', hz_thresh, ...
                             'method', 'multitaper', ...
                             'eegplotreject', 0, ...
                             'eegplotcom','',...
                             'eegplotplotallrej',0);
EEG = eeg_checkset(EEG);

% fprintf('%d/%d trial(s) marked for rejection\n', length(Irej), ...
%         EEG.trials);
