function chanrej = rej_chan_by_ntrial(EEG, thresh)

%EEG = eeg_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1);
%EEG = eeg_checkset(EEG);

rejglobalE = EEG.reject.rejglobalE;

chanrej = [];

if ~isempty(rejglobalE)
    perc = sum(rejglobalE,2)/EEG.trials;
    chanrej = find(perc >= thresh);
end
