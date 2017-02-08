function EEG = lix_loadIC(EEG, icamat)


EEG.icaweights = icamat.icaweights;
EEG.icasphere = icamat.icasphere;
EEG.icawinv = icamat.icawinv;
EEG.icachansind = icamat.icachansind;
EEG = eeg_checkset( EEG );