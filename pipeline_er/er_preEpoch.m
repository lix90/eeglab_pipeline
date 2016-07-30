clear, clc, close all
baseDir = '~/Data/gender-role-emotion-regulation/';
inputTag = 'merge';
outputTag = 'preEpoch';
icaTag = 'icaEpoch';
fileExtension = {'set', 'eeg'};
prefixPosition = 1;

brainTemplate = 'Spherical';
onlineRef = 'FCz';
appendOnlineRef = true;
offlineRef = {'TP9', 'TP10', 'M2'};
sampleRate = 250;
hiPassHzPreICA = [];
hiPassHz = 1;
marks = {'S 11', 'S 22', 'S 33', 'S 44', 'S 55'};
timeRange = [-1, 5];
reallyRejIC = 0;
EOG = [];
nTrialOrig = 200;
thresh = [];
prob = [6, 3];
kurt = [6, 3];
threshTrialPerChan = 100;
threshTrialPerSubj = 20;
reallyRejEpoch = 0;

%%--------------
inputDir = fullfile(baseDir, inputTag);
outputDir = fullfile(baseDir, outputTag);
icaDir = fullfile(baseDir, icaTag);
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

[inputFilename, id] = getFileInfo(inputDir, fileExtension, prefixPosition);

rmChans = {'HEOL', 'HEOR', 'HEOG', 'HEO', ...
           'VEOD', 'VEO', 'VEOU', 'VEOG', ...
           'M1', 'M2', 'TP9', 'TP10'};

for i = 1:2
    
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
    
    labels = {EEG.chanlocs.labels};
    % re-reference if necessary
    if ~strcmp(offlineRef, 'average')
        offlineRefReal = intersect(labels, offlineRef);
        if strcmpi(char(offlineRefReal), 'm2')
            indexM2 = find(ismember(labels, offlineRefReal));
            EEG.data(indexM2, :) = EEG.data(indexM2, :)/2;
        end
        EEG = pop_reref(EEG, find(ismember(labels, offlineRefReal)));
        EEG = eeg_checkset(EEG);
    elseif strcmp(offlineRef, 'average')
        EEG = pop_reref(EEG, []);
        EEG = eeg_checkset(EEG);
    elseif isempty(offlineRef)
        disp('not to be re-referenced')
    end
    
    EEG2 = EEG;
    % high pass filtering
    if exist('hiPassHzPreICA', 'var') && ~isempty(hiPassHzPreICA)
        EEG = pop_eegfiltnew(EEG, hiPassHzPreICA, 0);
        EEG = eeg_checkset(EEG);
    end
    
    % reject bad channels
    EEG2 = pop_eegfiltnew(EEG2, hiPassHz, 0);
    badChannels = eeg_detect_bad_channels(EEG2);
    EEG.etc.badChannels = badChannels;
    EEG = pop_select(EEG, 'nochannel', badChannels);
    EEG2 = [];
    
    % re-reference if offRef is average
    if strcmp(offlineRef, 'average')
        EEG = pop_reref(EEG, []);
        EEG = eeg_checkset(EEG);
    end

    % epoching
    EEG = pop_epoch(EEG, marks, timeRange);
    EEG = eeg_checkset(EEG);
    
    % baseline-zero
    EEG = pop_rmbase(EEG, []);
    
    % load icamat
    icaFile = sprintf('%s_%s.mat', id{i}, icaTag);
    load(fullfile(icaDir, icaFile));
    EEG.icawinv = x.icawinv;
    EEG.icasphere = x.icasphere;
    EEG.icaweights = x.icaweights;
    EEG = eeg_checkset(EEG, 'ica');
    
    %% reject epoch before reject ICs
    EEG = autoRejTrial(EEG, [], prob, kurt, 100, 1);
    
    %% reject ICs
    try
        EEG = rejBySASICA(EEG, EOG, reallyRejIC);
    catch
        disp('wrong');
    end

    % baseline-zero again
    EEG = pop_rmbase(EEG, []);
    % reject epochs
    EEG = autoRejTrial(EEG, thresh, prob, kurt, threshTrialPerChan, ...
                       reallyRejEpoch);
    % whether or not reject subject by percentage of trials rejected
    rej_or_not = rejSubj(EEG, threshTrialPerSubj, nTrialOrig);
    if rej_or_not
        textFile = fullfile(outputDir, sprintf('%s_subjRejected.txt', id{i}));
        fid = fopen(textFile, 'w');
        fprintf(fid, sprintf('subject %s rejected for too many bad epochs\n', ...
                             id{i}));
        fclose(fid);
    else
        % save dataset
        EEG = pop_saveset(EEG, 'filename', outputFilenameFull);
    end
    EEG = []; ALLEEG = []; CURRENTSET = [];
    
end
