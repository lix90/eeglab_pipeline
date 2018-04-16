function EEG = change_event_latency(EEG, events, lat)
% lat - s

if ~iscellstr(events)
    disp('Error: The events input must be cellstr!')
    return;
end

eventtypes = {EEG.event.type};
srate = EEG.srate;
lat_point = round(lat * srate, 0);

if ~all(ismember(events, eventtypes))
    disp('Error: some events to rename is not found in EEG.event.');
    return;
end

num_events = numel(events);

for i = 1:num_events
    ind = ismember(eventtypes, events{i});
    if isempty(ind)
        disp('Error: Events are not compatible.');
        return;        
    end
    lat_ = [EEG.event(ind).latency];
    indx = find(ind);
    for j = 1:numel(lat_)
        EEG.event(indx(j)).latency = lat_(j) - lat_point;
    end
end
EEG = eeg_checkset(EEG);
