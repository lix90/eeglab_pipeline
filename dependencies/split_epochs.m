function split_epochs(EEG, fname, event, timerange)

EEG = pop_epoch(EEG, event, timerange);
pop_saveset(EEG, 'filename', fname);