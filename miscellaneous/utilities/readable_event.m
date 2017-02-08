function EEG = readable_event(EEG, resp, stim, changeEvent, from, to)

% remove abundant marks
EEG = lix_check_event(EEG, resp, stim);
% change event name if neccesary
if changeEvent
  		EEG = lix_change_event(EEG, from, to);
end
EEG = eeg_checkset(EEG);