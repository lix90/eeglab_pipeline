%% eeglab pipeline for lqs: merge datasets
clear, clc, close

baseDir = '';
chanlocDir = '';
inputTag = '';
outputTag = 'epoch';
fileExtension = 'set';
prefixPosition = 1;
poolSize = 2;
marks = {'yes_neg_small', 'yes_neg_big', ...
        'yes_pos_small', 'yes_pos_big',...
        'no_neg_small', 'no_neg_big',...
        'no_pos_small', 'no_pos_big'};
timeRange = [-0.2, 1];

%%============================================

inputDir = fullfile(baseDir, inputTag);
outputDir = fullfile(baseDir, outputTag);
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
[inputFilename, id] = getFileInfo(inputDir, fileExtension, prefixPosition);

if exist('poolSize', 'var') && ~isempty(poolSize)
    setMatlabPool(poolSize)
end

setEEGLAB;

parfor i = 1:numel(id)

    outputFilename = sprintf('%s_%s.set', id{i}, outputTag);
    outputFilenameFull = fullfile(outputDir, outputFilename);
    if exist(outName, 'file'); warning('files already exist'); continue; end

    [EEG, ALLEEG, CURRENTSET] = importEEG(inputDir, inputFilename{i});
    
    % reject bad ICs
    EEG = pop_subcomp(EEG, [], 0);
    EEG = eeg_checkset(EEG);
    
    % interpolate channels
    EEG = eeg_interp(EEG, chanlocs, 'spherical');
    EEG = eeg_checkset(EEG);
    
    % epoch
    EEG = pop_epoch(EEG, marks, timeRange, 'epochinfo', 'yes');
    EEG = eeg_checkset(EEG);

    EEG.setname = sprintf('%s_%s', id{i}, outputTag);
    EEG = pop_saveset(EEG, 'filename', outputFilenameFull);
    ALLEEG = []; EEG = []; CURRENTSET = [];
    
end