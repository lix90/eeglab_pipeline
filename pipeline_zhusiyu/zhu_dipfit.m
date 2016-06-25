% function iris_dipfit
clear, clc
%%%%%% set directory
baseDir = 'E:\iris';
inputDir = 'E:\iris\ica';
if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end

outputDir = fullfile(baseDir, 'dipfit_spherical');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

%%%%%% baseline correction
BASE = [-800, 0];

%%%%%% dipfit parameters
RV = 1;
MODEL = 'Spherical'; % 'MNI' or 'Spherical'
%%%%%% channel location files
switch MODEL
  case 'MNI'
    locFile = 'standard_1005.elc';
    hdmfile = 'standard_vol.mat';
    mrifile = 'standard_mri.mat';
    chanfile = 'standard_1005.elc';
  case 'Spherical'
    locFile = 'standard-10-5-cap385.elp';
    hdmfile = 'standard_BESA.mat';
    mrifile = 'avg152t1.mat';
    chanfile = 'standard-10-5-cap385.elp';
end
hdmfileDir = dirname(which(hdmfile));
mrifileDir = dirname(which(mrifile));
chanfileDir = dirname(which(chanfile));
locDir = dirname(which(locFile));

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

    %%%%%%% average re-reference
    EEG = pop_reref(EEG, []);
    EEG = eeg_checkset(EEG);

    %%%%%% change channel location template
    EEG = pop_chanedit(EEG, 'lookup', locDir, 'setref',{['1:', int2str(size(EEG.data, 1))] 'average'});
    EEG = eeg_checkset(EEG);
    chanlocs = pop_chancenter(EEG.chanlocs, []);
    EEG.chanlocs = chanlocs;
    EEG = eeg_checkset(EEG);

    %%%%%% dipfitting
    nbcomp = size(EEG.icaact, 1);
    nbchan = size(EEG.data, 1);
    EEG = pop_dipfit_settings( EEG, ...
                               'hdmfile', hdmfileDir, ...
                               'coordformat', MODEL, ...
                               'mrifile', mrifileDir, ...
                               'chanfile', chanfileDir, ...
                               'chansel', [1:nbchan] );
    EEG = pop_dipfit_gridsearch(EEG, [1:nbcomp] , ...
                                [-85:17:85], [-85:17:85], [0:17:85], RV);
    EEG = pop_multifit( EEG, [1:nbcomp] , ...
                        'threshold', RV*100, ...
                        'plotopt', {'normlen' 'on'});
    EEG = eeg_checkset( EEG );

    %%%%%% save sets
    EEG.setname = strcat(ID{i}, '_dipfit');
    EEG = pop_saveset(EEG, 'filename', outName); % save set
    EEG = eeg_checkset( EEG ); 
    EEG = [];

end