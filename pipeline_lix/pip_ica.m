clear, clc, close all

% set directory
baseDir = '~/Data/yang_select';
inputDir = fullfile(baseDir, 'pre');
outputDir = fullfile(baseDir, 'ica');
icaDir = fullfile(baseDir, 'icamat');
poolsize = 4;

% epoch rejection
rej.rightRESP = {'S  7'};
rej.rejthreshold = 1;
rej.chanorcomp = 'channels';

% ica parameters
REF = 'average';
RANK = 'auto';

% prepare datasets
if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
if ~exist(icaDir, 'dir'); mkdir(icaDir); end
tmp = dir(fullfile(inputDir, '*.set'));
fileName = natsort({tmp.name});
nFile = numel(fileName);
id = get_prefix(fileName, 1);
id = natsort(unique(id));

% Open matlab pool
if matlabpool('size') < poolsize
   matlabpool local 4;
end

parfor i = 1:nFile

    % prepare output filename
    name = strcat(id{i}, '_ica.set');
    outName = fullfile(outputDir, name);
    EEGica = struct();
    icaName = strcat(id{i}, '_ica.mat');
    icaOutName = fullfile(icaDir, icaName);

    % check if file exists
    if exist(outName, 'file'); warning('files already exist'); continue; end
    fprintf('Loading (%i/%i %s)\n', i, nFile, fileName{i});

    % load dataset
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset( EEG );

    % re-reference again
    EEG = pop_reref(EEG, []);
    EEG = eeg_checkset(EEG);

    % preparing data for ica (reject epoch)
    EEG = lix_rej_epoch(EEG, rej);

    % baseline-zero'd
    % Note that if data consists of multiple discontinuous epochs, 
    % each epoch should be separately baseline-zero'd using
    EEG = pop_rmbase(EEG, []);
    
    % run ica
    EEG = lix_runica(EEG, REF, RANK); % run ica

    % save ica matrices
    EEGica.icaweights = EEG.icaweights;
    EEGica.icasphere = EEG.icasphere;
    EEGica.icawinv = EEG.icawinv;
    EEGica.icachansind = EEG.icachansind;
    parsave(icaOutName, EEGica);

    % save sets
    EEG.setname = strcat(id{i}, '_ica');
    EEG = pop_saveset(EEG, 'filename', outName); % save set
    EEG = eeg_checkset( EEG );
    EEG = [];

end