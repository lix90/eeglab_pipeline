function EEG = lix_change_event(EEG, from, to)
% change events names as you like
% parameters:
% 	from: events to change (cell array)
% 	  to: events change to (cell array)


events = {EEG.event(:).type};

num_from = numel(from);
num_to = numel(to);
if isequal(num_from, num_to)
    for i = 1:num_from
        ind = strcmpi(events, from{i});
        if ~isempty(ind)
            [EEG.event(ind).type] = deal(to{i});
        else
            error('events are not compatible\n');
        end
    end
    EEG = eeg_checkset(EEG);
else
    error('the number of events you set is not equal!');
end


