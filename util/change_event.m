function EEG = changeEvent(EEG, from, to)
% change events names as you like before epoching
% parameters:
% 	from: events to change (cell array)
% 	  to: events change to (cell array)
% by: lix, its.lix@outlook.com

if ~iscellstr(from) || ~iscellstr(to)
    disp('the 2nd & 3rd input must be cellstr!')
    return
end

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
    disp('the number of events you set is not equal!');
    return
end


