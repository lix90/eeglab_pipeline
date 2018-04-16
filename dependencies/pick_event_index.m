function ind = pick_event_index(EEG, event_ids, time_range)
% Pick events, return index of events

if ischar(event_ids)
    event_ids = {event_ids};
end

if ~exist('time_range', 'var')
    time_range = [];  % [] means whole epoch
end

% ids = pick_event_ids(EEG, 0);

% if isempty(time_range)
%     % Get epoch index
%     epochs = [EEG.event.epoch];
%     ind_ids = ismember(ids, event_ids);
%     ind = epochs(ind_ids);
% else
%     tmp = eeg_getepochevent(EEG, 'type', event_ids, 'timewin', time_range);
%     ind = find(~isnan(tmp));
% end

tmp = eeg_getepochevent(EEG, 'type', event_ids, 'timewin', time_range);
ind = ~isnan(tmp);
