%%%%%% set directory
baseDir = '~/Data/yang_select';
inputDir = fullfile(baseDir, 'ica');
if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end

outputDir = fullfile(baseDir, 'spherical');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

%%%%%% baseline correction
BASE = [-1000, 0];

%%%%%% dipfit parameters
RV = 1;
MODEL = 'MNI'; % 'MNI' or 'Spherical'

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
    name = strcat(ID{i}, '_dipfit.set');
    outName = fullfile(outputDir, name);

    %%%%%% check if file exists
    if exist(outName, 'file'); warning('files already exist'); continue; end
    fprintf('Loading (%i/%i %s)\n', i, nFile, fileName{i});

    %%%%%% load dataset
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset( EEG );

    %%%%%% baseline correction
    EEG = pop_rmbase(EEG, BASE);
    EEG = eeg_checkset(EEG);

    %%%%%% re-reference again
    EEG = pop_reref(EEG, []);
    EEG = eeg_checkset(EEG);

    %%%%%% dipfitting
    dipfitParams = setDipfitParams(EEG, MODEL);
    dipfitParams.RV = RV;
    dipfitParams.MODEL = MODEL;
    EEG = runDipFit(EEG, dipfitParams);

    %%%%%% save sets
    EEG.setname = strcat(ID{i}, '_dipfit');
    EEG = pop_saveset(EEG, 'filename', outName); % save set
    EEG = eeg_checkset( EEG );
    EEG = [];

end