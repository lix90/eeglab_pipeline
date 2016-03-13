function lix_chkbad

%%%%%% set directory
baseDir = 'F:\meng';
inputDir = 'F:\meng\merge';
outputDir = fullfile(baseDir, 'chkbad');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

%%%%%% preprocessing parameters
DS			= 250; % downsampling
HP 			= 1; 
MODEL 		= 'MNI'; % channel loacation file type 'Spherical' or 'MNI'
UNUSED	= {'HEOL', 'VEOD', 'HEOR', 'VEOU', 'M2'}; % lin

%%%%%% channel location files
switch MODEL
	case 'MNI'
		locFile = 'standard_1005.elc';
	case 'Spherical'
		locFile = 'standard-10-5-cap385.elp';
end
locDir = dirname(which(locFile));

%%%%%% prepare datasets
tmp = dir(fullfile(inputDir, '*.set'));
fileName = natsort({tmp.name});
nFile = numel(fileName);
ID = get_prefix(fileName, 1);
ID = natsort(unique(ID));

PREP.referenceType = 'robust';
PREP.referenceChannels = 1:58;
PREP.evaluationChannels = 1:58;
PREP.rereferencedChannels = 1:58;

%%%%%% Open matlab pool
lix_matpool(4);

%%%%%% start for loop
parfor i = 1:nFile
	%%%%%% prepare output filename
	name = strcat(ID{i}, '_chkbad.set');
	outName = fullfile(outputDir, name);

	%%%%%% check if file exists
	if exist(outName, 'file'); warning('files already exist'); continue; end
	
	%%%%%% load dataset
	EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
	EEG = eeg_checkset(EEG);

	%%%%%% add channel locations
	EEG = pop_chanedit(EEG, 'lookup', locDir);
	EEG = eeg_checkset(EEG);
	chanlocs = pop_chancenter(EEG.chanlocs, []);
	EEG.chanlocs = chanlocs;
	EEG = eeg_checkset(EEG);

	%%%%%% remove unused channels
	chanLabels = {EEG.chanlocs.labels};
	idx = lix_elecfind(chanLabels, UNUSED);
	EEG = pop_select(EEG,'nochannel', idx);
	EEG = eeg_checkset( EEG );

	%%%%%% check bad channels

	% [EEGclean, referenceOut] = performReference(EEG, PREP);
	% EEG.badchans.indix = referenceOut.interpolatedChannels.all;
	% chanlabels = {EEG.chanlocs.labels};
	% EEG.badchans.labels = chanlabels(EEG.badchans.indix);
	% EEGclean = [];
	arg_flatline = []; % default is 5
	arg_highpass = 'off';
	arg_channel = []; % default is 0.85
	arg_noisy = [];
	arg_burst = 'off';
	arg_window = 'off';
	EEG = clean_rawdata(EEG, ...
		arg_flatline, arg_highpass, arg_channel, arg_noisy, arg_burst, arg_window);

	%%%%%% save badchans matrix
	EEG = pop_saveset(EEG, 'filename', outName);
	EEG = [];

end