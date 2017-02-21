function ind = pick_channel_index(chanlocs_or_eeg, labels)
% Get index of channel labels.


if isstruct(chanlocs_or_eeg) && isfield(chanlocs_or_eeg, 'chanlocs')
    % EEG struct
    chan_labels = {chanlocs_or_eeg.chanlocs.labels};
elseif isstruct(chanlocs_or_eeg) && isfield(chanlocs_or_eeg, 'labels')
    % chanlocs struct
    chan_labels = {chanlocs_or_eeg.labels};
elseif iscell(chanlocs_or_eeg)
    % chanlocs labels cellstr array
    chan_labels = chanlocs_or_eeg;
end


ind = ismember(chan_labels, labels);

