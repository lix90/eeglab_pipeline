function iris_ica2

%%%%%% set directory
baseDir = 'F:\iris';
inputDir = 'F:\iris\ica';
if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end

outputDir = fullfile(baseDir, 'ica2');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

icaDir = fullfile(baseDir, 'icamat');
if ~exist(icaDir, 'dir'); mkdir(icaDir); end

%%%%%% epoch rejection
rej.rightRESP = [];
rej.rejthreshold = 1;
rej.chanorcomp = 'components';

%%%%%% ica parameters
REF = 'average';
RANK = 45;

%%%%%% prepare datasets
tmp = dir(fullfile(inputDir, '*.set'));
fileName = natsort({tmp.name});
nFile = numel(fileName);
ID = get_prefix(fileName, 1);
ID = natsort(unique(ID));

%%%%%% Open matlab pool
lix_matpool(4);

parfor i = 1:nFile
    
	%%%%%% prepare output filename
	name = strcat(ID{i}, '_ica2.set');
	outName = fullfile(outputDir, name);
    EEGica = struct();
	icaName = strcat(ID{i}, '_ica.mat');
	icaOutName = fullfile(icaDir, icaName);

	%%%%%% check if file exists
	if exist(outName, 'file'); warning('files already exist'); continue; end
	fprintf('Loading (%i/%i %s)\n', i, nFile, fileName{i});

	%%%%%% load dataset
	EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
	EEG = eeg_checkset( EEG );
    
	%%%%%% preparing data for ica (reject epoch)
	EEG = lix_rej_epoch(EEG, rej);

	%%%%%% run ica
	EEG = lix_runica(EEG, REF, RANK); % run ica

	%%%%%% save ica matrices
	EEGica.icaweights = EEG.icaweights;
	EEGica.icasphere = EEG.icasphere;
	EEGica.icawinv = EEG.icawinv;
	EEGica.icachansind = EEG.icachansind;
	parsave(icaOutName, EEGica);

	%%%%%% save sets
	EEG.setname = strcat(ID{i}, '_ica2');
    EEG = pop_saveset(EEG, 'filename', outName); % save set
    EEG = eeg_checkset( EEG ); 
    EEG = [];

end