clear, clc, close all

%% parameter setting
baseDir = '';
inputTag = 'merge';
outputTag = 'preMastoids';
sampleRate = 250;
hiPassHz = 0.01;
brainTemplate = 'Spherical';
onlineRef = 'FCz';
appendOnlineRef = true;
offlineRef = {'TP9', 'TP10'};
timeRange = [-1, 2];
marks = {'yes_neg_small', 'yes_neg_big', ...
        'yes_pos_small', 'yes_pos_big',...
        'no_neg_small', 'no_neg_big',...
        'no_pos_small', 'no_pos_big'};
badChanAutoRej = true;
fileExtension = 'eeg';
prefixPosition = 1;
poolSize = 2;

%%------------------------

inputDir = fullfile(baseDir, inputTag);
outputDir = fullfile(baseDir, outputTag);
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

[inputFilename, id] = getFileInfo(inputDir, fileExtension, prefixPosition);

rmChans = {'HEOL', 'HEOR', 'HEOG', 'HEO', ...
           'VEOD', 'VEO', 'VEOU', 'VEOG', ...
           'M1', 'M2', 'TP9', 'TP10'};

if exist('poolSize', 'var') && ~isempty(poolSize)
    setMatlabPool(poolSize)
end

setEEGLAB;

parfor i = 1:numel(id)

    outputFilename = strcat(id{i}, strcat('_', outputTag, '.set'));
    outputFilenameFull = fullfile(outputDir, outputFilename);
    if exist(outputFilenameFull, 'file'); warning('files already exist'); continue; end

    % import EEG dataset
    EEG = importEEG(inputDir, inputFilename{i});
    
    % down-sampling
    EEG = pop_resample(EEG, sampleRate);
    EEG = eeg_checkset(EEG);
    
    % high pass filtering
    EEG = pop_eegfiltnew(EEG, hiPassHz, 0);
    EEG = eeg_checkset(EEG);
    
    % add channel locations
    EEG = addChanLoc(EEG, brainTemplate, onlineRef, appendOnlineRef);

    % remove channels
    if ~strcmp(offlineRef, 'average')
        rmChansReal = setdiff(rmChans, offlineRef);
    else
        rmChansReal = rmChans;
    end
    EEG = pop_select(EEG, 'nochannel', rmChansReal);
    EEG = eeg_checkset(EEG);
    EEG.etc.origChanlocs = EEG.chanlocs;
    
    % re-reference if necessary
    if ~strcmp(offlineRef, 'average')
        EEG = pop_reref(EEG, find(ismember({EEG.chanlocs.labels}, offlineRef)));
    else
        EEG = pop_reref(EEG, []);
    end
    EEG = eeg_checkset(EEG);
    
    if badChanAutoRej
        % reject bad channels
        badChannels = eeg_detect_bad_channels(EEG);
        EEG.etc.badChannels = badChannels;
        EEG = pop_select(EEG, 'nochannel', badChannels);
    end
    
    % re-reference if offRef is average
    if strcmp(offlineRef, 'average')
        EEG = pop_reref(EEG, []);
        EEG = eeg_checkset(EEG);
    end

    % epoching
    EEG = pop_epoch(EEG, marks, timeRange, 'epochinfo', 'yes');
    EEG = eeg_checkset(EEG);
    
    EEG = pop_rmbase(EEG, []);
    EEG = eeg_checkset(EEG);

    % save dataset
    EEG = pop_saveset(EEG, 'filename', outputFilenameFull);
    EEG = [];

end