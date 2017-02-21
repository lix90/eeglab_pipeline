function EEG = set_offline_reference(EEG, offline_ref, exclude)

if ~exist('offline_ref', 'var')
    offline_ref = [];                   % average reference
end

if ~exist('exclude', 'var')
    exclude = {'bad', 'veo', 'heo', 'ear'};
end

if ischar(offline_ref) && strcmpi(offline_ref, 'average')
    offline_ref = [];
end

if iscell(offline_ref)
    offline_ref = find(pick_channel_index(offline_ref));
end

if ischar(exclude)
    exclude = {exclude};
end

supported_types = {'eeg', 'veo', 'heo', 'ecg', 'bad', 'ear'};
chan_labels = {EEG.chanlocs.labels};

if ~any(ismember(union(supported_types, chan_labels), exclude))
    disp('Error: channel types or labels is not found.');
    return;
end

exclude = find(pick_channel_types(EEG, exclude));
EEG = pop_reref(EEG, offline_ref, exclude);
