function ind = pick_channel_types(EEG, type)
% Pick channel according to its types
% (only support: eeg, veo, heo, ecg, bad, ear)

if nargin < 2
    disp('Error: Not enough argument.');
    return;
end

type_supported = {'eeg', 'veo', 'heo', 'ecg', 'bad', 'ear'};

if ~any(ismember(type_supported, type))
    help pick_channel_types;
    return;
end

chantypes = {EEG.chanlocs.type};
ind = ismember(chantypes, type);
