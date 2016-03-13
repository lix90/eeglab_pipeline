function EEG = lix_reref(EEG, offline_ref)

chanlocs = EEG.chanlocs;
% if ~isempty(offline_ref)
%     offline_ref_str = cellstrcat(offline_ref, ' ');
% end

if ~isempty(offline_ref)
% 	if strcmpi(chanlocs.ref, offline_ref_str) % check if is specific reference
		offline_ref_index = lix_elecfind(chanlocs, offline_ref);
		EEG = pop_reref(EEG, offline_ref_index);
		EEG = eeg_checkset(EEG);
% 	end
else
% 	if ~strcmpi(chanlocs.ref, 'average') | ~strcmpi(EEG.ref, 'averef')
		EEG = pop_reref(EEG, []);
		EEG = eeg_checkset(EEG);
% 	elseif strcmpi(chanlocs.ref, 'average') | strcmpi(EEG.ref, 'averef')
% 		disp('already average rereferenced')
% 		return
% 	end
end