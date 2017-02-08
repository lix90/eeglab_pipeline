function EEG = lix_check_event(EEG, resp, stim)

event = EEG.event;
types = {event.type}; % get all types
ntype = numel(types);
if ~isempty(resp)
  used_type = union(resp, stim);
else
  used_type = stim;
end
not_include = zeros(size(types));
for i = 1:ntype
  type_now = types{i};
  not_include(i) = ~any(strcmpi(used_type, type_now));
end
                                % event(logical(not_include)) = [];
EEG = pop_editeventvals(EEG, 'delete', find(not_include));
EEG = eeg_checkset(EEG);

types = {EEG.event.type};
latency = {EEG.event.latency};
not_include2 = zeros(size(types));
for i_resp = 1:numel(resp)
  resp_now = resp{i_resp};
  ind_resp_now = find(strcmpi(types, resp_now));
  for i_resp_now = 1:numel(ind_resp_now)
	ind2 = ind_resp_now(i_resp_now);
		                       % find the index whose latency is near 'resp_now'
	if ind2 > 1 && latency{ind2} - latency{ind2-1} < 10
	  not_include2(ind2-1) = 1;
	elseif ind2 < numel(types) && latency{ind2+1} - latency{ind2} < 10
	  not_include2(ind2+1) = 1;
	end
  end
end

                                % event(logical(not_include2)) = [];
EEG = pop_editeventvals(EEG, 'delete', find(not_include2));
EEG = eeg_checkset(EEG);
