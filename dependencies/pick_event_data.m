function outdata = pick_event_data(EEG, event_ids)

if ndims(EEG.data)~=3
    disp('EEG data is not epoched. Please epoch first.');
    return;
end

if ~exist('event_ids', 'var')
    event_ids = [];
end

if ischar(event_ids)
    event_ids = {event_ids};
end

if ~isempty(event_ids)
    idx = pick_event_index(EEG, event_ids);
    outdata = EEG.data(:,:,idx);
    if length(idx)==1
        outdata = squeeze(outdata);
    end
else
    outdata = EEG.data;
end
