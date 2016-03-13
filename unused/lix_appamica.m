function lix_appamica

% Data dirs
	basedir = filepath;
	readdir = [basedir 'raw\'];
	writdir = [basedir 'processed\'];
	if ~exist(writdir, 'dir'); mkdir(writdir); end

cd(writdir);
tmp = dir('*ica.mat');
icalist = {tmp.name}; icalist = sort(icalist);
tmp = dir('*preica.set');
sublist = {tmp.name}; sublist = sort(sublist);


[ALLEEG EEG CURRENTSET] = eeglab;
for iSub = 1:length(sublist)
	EEG = pop_loadset('filename', sublist{iSub}, 'filepath', pwd);
	EEG = eeg_checkset( EEG );
	outdir = [ writdir, icalist{iSub} ];
	EEG = eeg_loadamica( EEG, outdir );
	EEG = eeg_checkset ( EEG );
	EEG = pop_saveset( EEG, 'filename', [ writdir, sublist{iSub}(1:end-11), '_appica.set' ] );
	ALLEEG = []; EEG = [];
end