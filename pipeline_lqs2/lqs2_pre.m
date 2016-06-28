clear, clc, close all

% pipeline for pre-ica preprocessing
baseDir = '';
inputTag = '';
outputTag = '';
fileExtension = 'eeg';
prefixPosition = 1;
brainTemplate = 'Spherical';
onlineRef = 'FCz';
appendOnlineRef = true;
offlineRef = 'average';
sampleRate = 250;
hiPassHz = 0.01;

%%--------------

inputDir = fullfile(baseDir, inputTag);
outputDir = fullfile(baseDir, outputTag);
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
[inputFilename, id] = getFileInfo(inputDir, fileExtension, prefixPosition);

rmChans = {'HEOL', 'HEOR', 'HEOG', 'HEO', ...
           'VEOD', 'VEO', 'VEOU', 'VEOG', ...
           'M1', 'M2', 'TP9', 'TP10'};

setEEGLAB;

% for i = 1:numel(id)
for i = numel(id)
    
    outputFilename = sprintf('%s_%s.set', id{i}, outputTag);
    outputFilenameFull = fullfile(outputDir, outputFilename);
    
    if exist(outputFilenameFull, 'file')
        warning('files alrealy exist!')
        continue
    end
    
    % import dataset
    [EEG, ALLEEG, CURRENTSET] = importEEG(inputDir, inputFilename{i});
    
    % down-sampling
    EEG = pop_resample(EEG, sampleRate);
    EEG = eeg_checkset(EEG);
    
    % high pass filtering
    if exist('hiPassHz', 'var') && ~isempty(hiPassHz)
        EEG = pop_eegfiltnew(EEG, hiPassHz, 0);
        EEG = eeg_checkset(EEG);
    end
    
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
        EEG = eeg_checkset(EEG);
    elseif isempty(offlineRef)
        disp('not to be re-referenced')
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
    
    % save dataset
    EEG = pop_saveset(EEG, 'filename', outputFilenameFull);
    EEG = []; ALLEEG = []; CURRENTSET = [];
    
end
