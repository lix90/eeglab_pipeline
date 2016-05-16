function lix_inspection(params)

inDIR = params.epochDIR;

% find file names
tmp = dir([inDIR, filesep, '*.set']);
sub = natsort({tmp.name});

[ALLEEG EEG ALLCOM] = eeglab;
for i = 1:numel(sub)
	EEG = pop_loadset('filename',sub{i},'filepath',inDIR);
	[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
	EEG = eeg_checkset( EEG );
	pop_eegplot( EEG, 1, 1, 0);
	pause
	EEG = eeg_checkset( EEG );
	EEG = pop_saveset( EEG, 'savemode','resave');
	[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
	ALLEEG = []; EEG = [];
end