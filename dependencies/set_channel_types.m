function EEG = set_channel_types(EEG, chan_labels, type)
% Set channels types: eeg, veo, heo, ecg, bad, ear.
% chan_labels: cell str or str
% type: str

if nargin < 3
    disp('Error: The number of input arguments must be 3.');
    return;
end

if ~ischar(type)
    disp('Error: The value of type must be string.');
    return;
end

type_supported = {'eeg', 'bad', 'veo', 'heo', 'ecg', 'ear'};
if ~any(ismember(type_supported, type))
    help set_channel_types;
    return;
end

if isempty(chan_labels)
    return;
end

chanlocs = EEG.chanlocs;

idx_e = find(pick_channel_index(EEG, chan_labels));

for i = 1:length(idx_e)
    chanlocs(idx_e(i)).type = type;
end

EEG.chanlocs = chanlocs;
