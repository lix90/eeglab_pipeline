clear, clc, close all

baseDir = '~/Data/mx_music/'; %
inputDir = fullfile(baseDir, 'raw'); %
outputDir = fullfile(baseDir, 'pre2'); %
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

sampleRate = 250;
hiPassHz = 0.5;
brainTemplate = 'Spherical';
onlineRef = 'FCz';
appendOnlineRef = true;
offlineRef = {'TP9', 'TP10'};
timeRange = [-1, 2];
marks = {'S 53', 'S 58', 'S103', 'S108'};
badChanAutoRej = 1;
fileExtension = 'eeg';
prefixPosition = 1;
poolsize = [];
 

%%------------------------
[inputFilename, id] = getFileInfo(inputDir, fileExtension, prefixPosition);

rmChans = {'HEOL', 'HEOR', 'HEOG', 'HEO', ...
           'VEOD', 'VEO', 'VEOU', 'VEOG', ...
           'M1', 'M2', 'TP9', 'TP10'};

if exist('poolSize', 'var') && ~isempty(poolSize)
    setMatlabPool(poolSize)
end

parfor i = 1:numel(id)

    outputFilename = strcat(id{i}, '_pre.set');
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
        rmChansNew = setdiff(rmChans, offlineRef);
    else
        rmChansNew = rmChans;
    end
    EEG = pop_select(EEG, 'nochannel', rmChansNew);
    EEG = eeg_checkset(EEG);
    EEG.etc.origChanlocs = EEG.chanlocs;
    
    % re-reference if necessary
    if ~strcmp(offlineRef, 'average')
        EEG = pop_reref(EEG, find(ismember({EEG.chanlocs.labels}, offlineRef)));
        EEG = eeg_checkset(EEG);
    end
    
    % reject bad channels
    badChannels = eeg_detect_bad_channels(EEG);
    EEG.etc.badChannels = badChannels;
    EEG = pop_select(EEG, 'nochannel', badChannels);
    
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