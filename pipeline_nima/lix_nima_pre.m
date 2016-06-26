% pipeline for pre-ica preprocessing

baseDir = '~/Data/gender-role-emotion-regulation/';
inputDir = fullfile(baseDir, 'merge');
outputDir = fullfile(baseDir, 'pre_nima_test');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

fileExtension = 'set';
prefixPosition = 1;
brainTemplate = 'Spherical';
onlineRef = 'FCz';
appendOnlineRef = true;
offlineRef = 'average';
sampleRate = 250;
hiPassHz = 0.1;

[inputFilename, id] = getFileInfo(inputDir, fileExtension, prefixPosition);

% for i = 1:numel(id)
for i = 2:3
    outputFilename = sprintf('%s_pre.set', id{i});
    outputFilenameFull = fullfile(outputDir, outputFilename);
    
    if exist(outputFilenameFull, 'file')
        warning('files alrealy exist!')
        continue
    end
    
    % import dataset
    EEG = importEEG(inputDir, inputFilename{i});
    
    % add channel locations
    EEG = addChanLoc(EEG, brainTemplate, onlineRef, appendOnlineRef);
    
    % down-sampling
    EEG = pop_resample(EEG, sampleRate);
    EEG = eeg_checkset(EEG);
    
    % high pass filtering
    EEG = pop_eegfiltnew(EEG, hiPassHz, 0);
    EEG = eeg_checkset(EEG);

    % remove channels
    rmChans = {'HEOL', 'HEOR', 'HEOG', 'HEO', ...
               'VEOD', 'VEO', 'VEOU', 'VEOG', ...
               'M1', 'M2', 'TP9', 'TP10'};
    
    if ~strcmp(offlineRef, 'average')
        rmChans = setdiff(rmChans, offlineRef);
    end
    
    EEG = pop_select(EEG, 'nochannel', rmChans);
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
    
    % save dataset
    EEG = pop_saveset(EEG, 'filename', outputFilenameFull);
    EEG = [];
    
end
