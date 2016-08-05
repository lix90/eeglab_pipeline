function [EEG, info] = rejEpochAuto(EEG, thresh_param, trends_param, spectra_param, threshChan, reject)

info.orig_ntrial = EEG.trials;
info.orig_chanlocs = EEG.chanlocs;
% identify epoch
fprintf('start: the 1st automatical bad epoch detecting\n');
EEG = rejDetectEpoch(EEG, thresh_param, trends_param, spectra_param);
if ~isempty(EEG.reject.rejglobalE) && exist('threshChan', 'var')
    perBadEpochInChannels = sum(EEG.reject.rejglobalE, 2)/EEG.trials;
    rej_ch = find(perBadEpochInChannels > threshChan);
    if ~isempty(rej_ch)
        fprintf('start: reject channels');
        EEG = pop_select(EEG, 'nochannel', rej_ch);
        EEG = eeg_checkset(EEG);
        % identify epoch again
        fprintf('start: the 2nd automatical bad epoch rejecting\n');
        EEG = rejDetectEpoch(EEG, thresh_param, trends_param, spectra_param);        
    end
end

if reject
    indexRej = EEG.reject.rejglobal;
    EEG = pop_rejepoch(EEG, indexRej ,0);
end

info.rej_epoch_auto = EEG.reject.rejglobal;
labels = {info.orig_chanlocs.labels};
info.rej_chan_by_epoch = labels(rej_ch);

