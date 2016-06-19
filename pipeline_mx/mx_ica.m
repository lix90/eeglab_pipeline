clear, clc, close all

% set directory
baseDir = '~/Data/lqs_gambling/';
inputDir = fullfile(baseDir, 'pre');
outputDir = fullfile(baseDir, 'ica');
poolsize = 4;
n_prefix = 1;

% epoch rejection
rightRESP = [];
chanorcomp = 'channels';

% prepare datasets
if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
tmp = dir(fullfile(inputDir, '*.set'));
fileName = natsort({tmp.name});
nFile = numel(fileName);
ID = get_prefix(fileName, n_prefix);
ID = natsort(unique(ID));

% Open matlab pool
if matlabpool('size') == 0
    matlabpool('open', poolsize);
else
    matlabpool close
    matlabpool('open', poolsize);
end

fprintf('start loop')
parfor i = 1:nFile

    % prepare output filename
    name = strcat(ID{i}, '_ica.set');
    outName = fullfile(outputDir, name);
    % check if file exists
    if exist(outName, 'file'); warning('files already exist'); continue; end
    fprintf('Loading (%i/%i %s)\n', i, nFile, fileName{i});

    % load dataset
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset( EEG );
    
    % preparing data for ica (reject epoch)
    EEG = lix_rej_epoch(EEG, rightRESP, chanorcomp);
    EEG = pop_reref(EEG, []);

    % run ica
    EEG = pop_runica(EEG, 'extended', 1, 'interupt', 'off');

    % save sets
    EEG.setname = strcat(ID{i}, '_ica');
    EEG = pop_saveset(EEG, 'filename', outName); % save set
    EEG = eeg_checkset( EEG );
    EEG = [];

end
