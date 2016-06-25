%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

datasetDir = ' '; % directory of datasets used to add channel location
outputDir = ' '; 
onlineRef = 'M1';
offlineRef = {'M1', 'M2'};

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

filelists = dir(fullfile(datasetDir, '*.set'));
filelists = {filelists.name};
nFiles = numel(filelists);

tmpDir = which('standard_1005.elc'); % BESA template of channel location
if ~isempty(strfind(tmpDir, '\'))
	locDir = strrep(tmpDir, '\', '\\'); 
else
	locDir = indir;
end 

for i = 1:nFiles
	EEG = [];

	% output filename
	name = strcat(filelists{i}(1:end-4), '_locs.set');
	outName = fullfile(outputDir, name);

	% load data
	EEG = pop_loadset('filename', filelists{i}, 'filepath', datasetDir);
	EEG = eeg_checkset(EEG);

	% add channel locations
	nchan = size(EEG.data,1);
	nRef = nchan+1;
	EEG=pop_chanedit(EEG, ...
		'lookup', locDir, ...
		'append',nchan, ...
		'changefield',{nRef 'labels' onlineRef}, ...
		'lookup',locDir,...
		'setref',{['1:', int2str(nRef)] onlineRef});

	% retain online reference
	EEG = pop_reref( EEG, [], ...
					'refloc', struct('labels', onlineRef,...
					'type', [],...
					'theta', [],...
					'radius', [],...
					'X', [],...
					'Y', [],...
					'Z', [],...
					'sph_theta', [],...
					'sph_phi', [],...
					'sph_radius', [],...
					'urchan', nchan+1,...
					'ref', onlineRef,...
					'datachan', {0}));
	EEG = eeg_checkset(EEG);
	EEG = pop_chanedit(EEG, 'lookup', locDir, ... 
		'setref',{['1:', int2str(nRef)] onlineRef});
	EEG = eeg_checkset(EEG);
	
	% re-reference to offlineRef
	EEG = pop_reref(EEG, offlineRef);
	EEG = eeg_checkset(EEG);

	% save dataset
	EEG = pop_saveset(EEG, 'filename', outName);
	EEG = [];
end