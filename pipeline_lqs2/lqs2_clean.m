%% eeglab pipeline for lqs
clear, clc, close

baseDir = '';
inputTag = '';
outputTag = 'clean';
baseline = [-200, 0];
rightRESP = [];
fileExtension = 'set';
prefixPosition = 1;
poolSize = 4;

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

    outputFilename = strcat(id{i}, strcat('_', outputTag, '.set'));
    outputFilenameFull = fullfile(outputDir, outputFilename);
    if exist(outName, 'file'); warning('files already exist'); continue; end
    fprintf('Merging subject %i/%i\n', i, numel(id));

    [EEG, ALLEEG, CURRENTSET] = importEEG(inputDir, inputFilename{i});
    
    % reject bad epochs
    EEG = rejEpoch(EEG, rightRESP, 'channels');
    EEG = eeg_checkset(EEG);
    
    % baseline correction
    EEG = pop_rmbase(EEG, baseline);
    EEG = eeg_checkset(EEG);
    
    EEG.setname = sprintf('%s_%s', id{i}, outputTag);
    EEG = pop_saveset(EEG, 'filename', outputFilenameFull);
    ALLEEG = []; EEG = []; CURRENTSET = [];
    
end