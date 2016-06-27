%% eeglab pipeline for lqs: merge datasets
clear, clc, close

baseDir = '~/Data/lqs_gambling/';
inputTag = 'change_event';
outputTag = 'merge';
fileExtension = 'set';
prefixPosition = 1;
poolSize = 2;

%%============================================

inputDir = fullfile(baseDir, inputTag);
outputDir = fullfile(baseDir, outputTag);
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

[inputFilename, id] = getFileInfo(inputDir, fileExtension, prefixPosition);

if exist('poolSize', 'var') && ~isempty(poolSize)
    setMatlabPool(poolSize)
end

setEEGLAB;

for i = 1:numel(id)

    ALLEEG = []; EEG = []; CURRENTSET = 0;

    outputFilename = strcat(id{i}, strcat('_', outputTag, '.set'));
    outputFilenameFull = fullfile(outputDir, outputFilename);
    if exist(outName, 'file'); warning('files already exist'); continue; end
    fprintf('Merging subject %i/%i\n', i, numel(id));
    
    tmp = dir(fullfile(inputDir, strcat(id{i}, '_*.', fileExtension)));
    setMerge = {tmp.name};
    % load set
    for j = 1:length(setMerge)
        switch fileExtension
          case 'eeg'
            EEG = pop_fileio(fullfile(inputDir, setMerge{j}));
          case 'set'
            EEG = pop_loadset('filename', setMerge{j}, 'filepath', inputDir);
          case 'cnt'
            EEG = pop_loadcnt(fullfile(inputDir, setMerge{j}), 'keystroke', 'on');
        end
        [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, j);
        EEG = eeg_checkset(EEG);
    end
    % merge set
    N = length(ALLEEG);
    if N > 1
        EEG = pop_mergeset(ALLEEG, 1:N, 0);
        EEG = eeg_checkset(EEG);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,...
                                             'overwrite','on');
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        EEG = eeg_checkset(EEG);
    end
    EEG.setname = strcat(id{i}, strcat('_', outputTag));
    EEG = pop_saveset(EEG, 'filename', outputFilenameFull);
    ALLEEG = []; EEG = []; CURRENTSET = 0;
    
end