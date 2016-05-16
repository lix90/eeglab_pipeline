function EEG = lix_runica(EEG, offline_ref, ranknum)

% offline_ref
isAvgRef = strcmpi(offline_ref, 'average');
if ischar(ranknum) && strcmpi(ranknum, 'auto')
	isICA = isempty(EEG.icaact);
	% isMark = any(EEG.reject.gcompreject);
	% numMark = numel(find(EEG.reject.gcompreject));
	switch isICA
	case 0
		num_ic = size(EEG.icaact, 1);
		r = num_ic;
		EEG = pop_runica(EEG, 'extended',1, 'pca', r, 'interupt', 'off');
	case 1 % if icaact is empty, use channel num
		num_ch = size(EEG.data, 1);
		if isAvgRef
			r = num_ch - 1;
			EEG = pop_runica(EEG,'extended',1, 'pca', r, 'interupt', 'off');
		else
			EEG = pop_runica(EEG,'extended',1, 'interupt', 'off');
		end
	end
elseif isnumeric(ranknum) && ranknum > 0
	r = ranknum;
	EEG = pop_runica(EEG,'extended',1, 'pca', r, 'interupt', 'off');
end
EEG = eeg_checkset(EEG);