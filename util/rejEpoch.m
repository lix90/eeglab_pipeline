function EEG = rejEpoch(EEG, rightRESP, chanorcomp)

% rightRESP
% wrong
% bad

m = zeros(1, size(EEG.data, 3));
if strcmpi(chanorcomp, 'channels') % chan
	if isempty(EEG.reject.rejmanual); EEG.reject.rejmanual = m; end
	if isempty(EEG.reject.rejjp); EEG.reject.rejjp = m; end
	if isempty(EEG.reject.rejkurt); EEG.reject.rejkurt = m; end
	if isempty(EEG.reject.rejthresh); EEG.reject.rejthresh = m; end
	if isempty(EEG.reject.rejconst); EEG.reject.rejconst = m; end
	rejall = EEG.reject.rejmanual + EEG.reject.rejjp + ...
	 EEG.reject.rejkurt + EEG.reject.rejthresh + EEG.reject.rejconst;
elseif strcmpi(chanorcomp, 'components') % icaact
	if isempty(EEG.reject.icarejmanual); EEG.reject.icarejmanual = m; end
	if isempty(EEG.reject.icarejjp); EEG.reject.icarejjp = m; end
	if isempty(EEG.reject.icarejkurt); EEG.reject.icarejkurt = m; end
	if isempty(EEG.reject.icarejthresh); EEG.reject.icarejthresh = m; end
	if isempty(EEG.reject.icarejconst); EEG.reject.icarejconst = m; end
	rejall = EEG.reject.icarejmanual + EEG.reject.icarejjp + ...
	 EEG.reject.icarejkurt + EEG.reject.icarejthresh + EEG.reject.icarejconst;
else
	disp('the alternatives of reject epoch can only be channels or components');
	return
end
bad = find(rejall);

% mark wrong epoch
wrong = [];
if ~isempty(rightRESP)
    n = EEG.trials;
    rightresp = zeros(1,n);
    for i = 1:n
        test = ismember(EEG.epoch(1,i).eventtype, rightRESP);
        if any(test)
            rightresp(i) = 1;
        end
    end
    wrong = find(~rightresp);% reject wrong response (containing non-responses)
end

idxRej = union(bad, wrong);

EEG = pop_select(EEG, 'notrial', idxRej);
EEG = eeg_checkset(EEG);
