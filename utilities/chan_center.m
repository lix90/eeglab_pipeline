function EEG = chan_center(EEG);

center_chanlocs = pop_chancenter(EEG.chanlocs, [], []);
EEG.chanlocs = center_chanlocs;
EEG = eeg_checkset(EEG);