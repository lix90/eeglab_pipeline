function EEG = lix_rej_comp(EEG)

badICs = find(EEG.reject.gcompreject);
EEG = pop_subcomp(EEG, badICs);
EEG = eeg_checkset(EEG);