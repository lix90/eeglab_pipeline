icaDIR = '';
nonicaDIR = '';
saveDIR = '';

icasubname = {'',...
				};


[ALLEEG, EEG, CURRENTSET] = eeglab;
for i = 1:length(icasubname)
%% 1. load ica data
	filename_ica = [icaDIR, filesep, icasubname{i}];
	EEG = pop_loadset('filename', filename_ica, 'filepath', icaDIR);
	[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
	EEG = eeg_checkset(EEG);
%% 2. save ica
	TMP.
%% 3. load non-ica data
	filename_nonica = [nonicaDIR, filesep, icasubname{i}];
	EEG = pop_loadset('filename', filename_nonica, 'filepath', nonicaDIR);
	[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
	EEG = eeg_checkset(EEG);
%% 4. apply ica to non-ica data
	EEG.
%% 5. save file
	EEG = eeg_checkset(EEG);
	EEG = pop_saveset(EEG, 'filename', outName);
end