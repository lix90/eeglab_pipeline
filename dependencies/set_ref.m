function EEG = set_ref(EEG, refs, exclud)

if ~exist('refs', 'var')
    refs = [];
end

if ~exist('exclud', 'var');
   exclud = find(pick_channel_types(EEG, {'veo', 'heo', 'ecg', 'bad', 'ear'}));
end

labels = lower({EEG.chanlocs.labels});
if ~is_avgref(refs)
    EEG = pop_reref(EEG, find(ismember(labels, lower(refs))));
    EEG = set_ref_label(EEG, str_join(refs, ' '));
else
    EEG = set_ref_avg(EEG, exclud);
end
EEG = eeg_checkset(EEG);
