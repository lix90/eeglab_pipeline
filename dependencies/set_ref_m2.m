function EEG = set_ref_m2(EEG)
% suitable for the dataset with M1 as online reference
% and re-referenced to M1 and M2.

labels = lower({EEG.chanlocs.labels});

if ~any(ismember(labels, 'm2'))
    error('There no M2 in this dateset.');
end

im2 = ismember(labels, 'm2');
EEG.data(im2, :) = EEG.data(im2, :)/2;
EEG = eeg_checkset(EEG);

EEG = pop_reref(EEG, find(ismember(labels, 'm2')));

