function ids = get_event_ids(EEG, want_unique)
% Get event types/ids

if ~exist('want_unique', 'var')
    want_unique = true;
end

if want_unique
    ids = unique({EEG.event.type});
else
    ids = {EEG.event.type};
end
