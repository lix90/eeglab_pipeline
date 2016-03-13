function EEG = re_ref(EEG, ref_type)

if ischar(ref_type) && strcmpi(ref_type, 'average')
	EEG = pop_reref(EEG, []);
	EEG = eeg_checkset(EEG);
else
	if iscellstr(ref_type)
		ref_ind = lix_elecfind(EEG.chanlocs, ref_type);
		EEG = pop_reref(EEG, ref_ind);
		EEG = eeg_checkset(EEG);
	else
		disp('ref_type must be string or cell string array')
		return
	end
end