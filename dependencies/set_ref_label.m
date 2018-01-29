function EEG = set_ref_label(EEG, lab)

for i = 1:length(EEG.chanlocs)
   EEG.chanlocs(i).ref = lab;
end

EEG = eeg_checkset(EEG);
