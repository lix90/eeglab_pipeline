function lix_epoch

%%%%%% set directory
baseDir = 'F:\meng';
inputDir = 'F:\meng\pre';
outputDir = fullfile(baseDir, 'epoch');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

%%%%%% preprocessing parameters
REF			= 'average';
CHANGE 	= true; % change event name
FROM  		= {'S 12', 'S 13', 'S 14'}; 
STIM 		= {'S 12', 'S 13', 'S 14'}; 
RESP          	= {'S  3', 'S  4', 'S  5'};
TO			= {'neutral', 'lowNegative', 'highNegative'};
EPOCHTIME = [-1, 1.8]; % epoch time range

%%%%%% prepare datasets
tmp = dir(fullfile(inputDir, '*.set'));
fileName = natsort({tmp.name});
nFile = numel(fileName);
ID = get_prefix(fileName, 1);
ID = natsort(unique(ID));

%%%%%% Open matlab pool
lix_matpool(4);

%%%%%% start for loop
parfor i = 1:nFile
	%%%%%% prepare output filename
	name = strcat(ID{i}, '_epoch.set');
	outName = fullfile(outputDir, name);

	%%%%%% check if file exists
	if exist(outName, 'file'); warning('files already exist'); continue; end
	
	%%%%%% load dataset
	EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
	EEG = eeg_checkset(EEG);

	%%%%%% re-reference
	if strcmpi(REF, 'average')
		EEG = pop_reref(EEG, []);
	elseif iscellstr(REF)
		indRef = lix_elecfind(chanLabels, REF);
		EEG = pop_reref(EEG, indRef);
	end
	EEG = eeg_checkset(EEG);

	%%%%%% change events
	EEG = readable_event(EEG, RESP, STIM, CHANGE, FROM, TO);
	
	%%%%%% epoch
    	if CHANGE
	    	MARKS = unique(TO);
    	else
	    	MARKS = unique(FROM);
    	end
	EEG = pop_epoch(EEG, MARKS, EPOCHTIME);
	EEG = eeg_checkset(EEG);

	%%%%%% save dataset
	EEG = pop_saveset(EEG, 'filename', outName);
	EEG = [];

end