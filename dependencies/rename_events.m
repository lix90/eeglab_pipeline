function EEG = rename_events(EEG, from_ids, to_ids)
% Rename events names as you like before epoching
% parameters:
% 	from_ids: events to change (cell array)
% 	  to_ids: events change to_ids (cell array)
% by: lix, its.lix@outlook.com

if ~iscellstr(from_ids) || ~iscellstr(to_ids)
    disp('Error: The from_ids & to_ids input must be cellstr!')
    return;
end

events = {EEG.event.type};

if isnumeric(events{1})
   events = cellfun(@num2cellstr, events);
end

if ~all(ismember(from_ids, events))
    disp('Error: some events to rename is not found in EEG.event.');
    %return;
end

num_from_ids = numel(from_ids);
num_to_ids = numel(to_ids);

if ~isequal(num_from_ids, num_to_ids)
    disp('Error: the number of events you set is not equal!');
    return;
end

for i = 1:num_from_ids
    ind = ismember(events, from_ids{i});
    if isempty(ind)
        disp('Error: Events are not compatible.');
        continue;        
    end
    [EEG.event(ind).type] = deal(to_ids{i});
end

EEG = eeg_checkset(EEG);



