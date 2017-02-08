function EEG = lix_checkepoch(EEG, str, pos)
% str = 'pain';
% pos = 'end'; % end or start

orig_epoch = EEG.epoch;
marks = [];

epochs = EEG.epoch;
nepoch = numel(epochs);

for i = 1:nepoch
	epoch_now = epochs(1, i);
	num_latency = numel(epoch_now.eventlatency);
	latency_now = epoch_now.eventlatency;
	type_now = epoch_now.eventtype;
	if num_latency == 2 && latency_now{1}+latency_now{2}<100
		marks = [marks, i];
	elseif num_latency >= 3 && latency_now{2}+latency_now{3}<100
		marks = [marks, i];
	end
end
EEG.marks = marks;

m = marks-1;
for j = length(m):-1:1
	ind = m(j);
	eventtype = EEG.epoch(1,ind).eventtype;
	urevent = EEG.epoch(1,ind).eventurevent;
	if ~isempty(strfind(eventtype{2}, str))
		% markrej = [markrej, urevent(2)];
		EEG.epoch(1,ind).event(2) = [];
		EEG.epoch(1,ind).eventtype(2) = [];
		EEG.epoch(1,ind).eventvalue(2) = [];
		EEG.epoch(1,ind).eventlatency(2) = [];
		EEG.epoch(1,ind).eventduration(2) = [];
		EEG.epoch(1,ind).eventurevent(2) = [];
		EEG.event(urevent{2}) = [];
	end
end
EEG = eeg_checkset(EEG);

EEG = pop_select(EEG, 'notrial', marks);
fprintf('reject abundant %i epochs\n', numel(marks));
EEG = eeg_checkset(EEG);

% if nargout == 2
%     x = marks;
% elseif nargout == 3
%     x = marks;
%     y = orig_epoch;
% end

% for itype = 1:numel(type)
% 	if ~isempty(strfind(type(itype), str)) && EEG.epoch(1,ind).eventlatency(itype) > 0
% 		EEG.epoch(1,ind).event(itype) = [];
% 		EEG.epoch(1,ind).eventtype(itype) = [];
% 		EEG.epoch(1,ind).eventvalue(itype) = [];
% 		EEG.epoch(1,ind).eventlatency(itype) = [];
% 		EEG.epoch(1,ind).eventduration(itype) = [];
% 		EEG.epoch(1,ind).eventurevent(itype) = [];
% 	end
% end