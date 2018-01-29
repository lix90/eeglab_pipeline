function EEG = set_ref_avg(EEG, exclud)

if ~exist('exclud', 'var');
   exclud = find(ismember(pick_channel_types(EEG, {'veo', ...
                       'heo', 'ecg', 'bad', 'ear'})));
end

EEG = pop_reref(EEG, [], 'exclude', exclud);
EEG = eeg_checkset(EEG);
