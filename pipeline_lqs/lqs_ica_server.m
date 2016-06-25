clear, clc, close all
% addpah
fprintf('adding path');
lix_scripts_path = '/nfs/data1/YuanJiajin/Lix/lix_scripts';
eeglab_path = '/nfs/data1/YuanJiajin/Lix/eeglab_dev';
addpath(genpath(lix_scripts_path));
addpath(genpath(eeglab_path));

% set directory
baseDir = '/nfs/data1/YuanJiajin/Lix/lqs/';
inputDir = fullfile(baseDir, 'pre3');
outputDir = fullfile(baseDir, 'ica');
poolsize = 12;

% epoch rejection
rightRESP = [];
chanorcomp = 'channels';

% ica parameters
REF = 'average';
RANK = 'auto';

% prepare datasets
if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
tmp = dir(fullfile(inputDir, '*.set'));
fileName = natsort({tmp.name});
nFile = numel(fileName);
id = get_prefix(fileName, 1);
id = natsort(unique(id));

% Open matlab pool
if matlabpool('size') == 0
    matlabpool('open', poolsize);
else
    matlabpool close
    matlabpool('open', poolsize);
end

Fprintf('start loop')
parfor i = 1:nFile

    % prepare output filename
    name = strcat(id{i}, '_ica.set');
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

    % % baseline-zero'd
    % % Note that if data consists of multiple discontinuous epochs, 
    % % each epoch should be separately baseline-zero'd using
    % EEG = pop_rmbase(EEG, []);
    
    % run ica
    EEG = lix_runica(EEG, REF, RANK); % run ica
    
    % save sets
    EEG.setname = strcat(id{i}, '_ica');
    EEG = pop_saveset(EEG, 'filename', outName); % save set
    EEG = eeg_checkset( EEG );
    EEG = [];

end
