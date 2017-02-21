function EEG = set_montage(EEG, chanlocs)

EEG.chanlocs = chanlocs;
EEG = eeg_checkset(EEG);
