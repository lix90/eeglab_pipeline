function zhu_ica

%%%%%% set directory
baseDir = 'E:\Thelma\zhu';
inputDir = fullfile(baseDir, 'pre');
if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end

outputDir = fullfile(baseDir, 'ica');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

icaDir = fullfile(baseDir, 'icamat');
if ~exist(icaDir, 'dir'); mkdir(icaDir); end

%%%%%% epoch rejection
rej.rightRESP = [];
rej.rejthreshold = 1;
rej.chanorcomp = 'channels';

%%%%%% baseline parameter
BASE = [-1000, 0];

%%%%%% ica parameters
REF = {'TP9', 'TP10'};
RANK = 50;

%%%%%% prepare datasets
tmp = dir(fullfile(inputDir, '*.set'));
fileName = natsort({tmp.name});
nFile = numel(fileName);
ID = get_prefix(fileName, 1);
ID = natsort(unique(ID));

%%%%%% Open matlab pool
% lix_matpool(4);

for i = 1:nFile
    
	%%%%%% prepare output filename
	name = strcat(ID{i}, '_ica.set');
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
    nbchan = size(EEG.data, 1);
    if nbchan < 50
        EEG = lix_runica(EEG, REF, nbchan); % run ica
    else
        EEG = lix_runica(EEG, REF, RANK);
    end

	%%%%%% save ica matrices
	EEGica.icaweights = EEG.icaweights;
	EEGica.icasphere = EEG.icasphere;
	EEGica.icawinv = EEG.icawinv;
	EEGica.icachansind = EEG.icachansind;
	parsave(icaOutName, EEGica);
    
    %%%%%% baseline correction
    EEG = pop_rmbase(EEG, BASE);
    EEG = eeg_checkset( EEG );

	%%%%%% save sets
	EEG.setname = strcat(ID{i}, '_ica');
    EEG = pop_saveset(EEG, 'filename', outName); % save set
    EEG = eeg_checkset( EEG ); 
    EEG = [];

end