clear, clc, close all
baseDir = '~/Data/gender-role-emotion-regulation/';
inputTag = 'merge';
outputTag = 'preICA2';
fileExtension = {'set', 'eeg'};
prefixPosition = 1;

brainTemplate = 'Spherical';
onlineRef = 'FCz';
appendOnlineRef = true;
offlineRef = {'TP9', 'TP10', 'M2'};

sampleRate = 250;
hipass = 1;
lowpass = [];
marks = {'S 11', 'S 22', 'S 33', 'S 44', 'S 55'};
timeRange = [-1, 5];

flatline = 5;
mincorr = 0.4;
linenoisy = 4;

thresh_chan = 0.1;
reject = 1;
thresh_param.low_thresh = -500;
thresh_param.up_thresh = 500;
trends_param.slope = 200;
trends_param.r2 = 0.2;
spectra_param.threshold = [-35, 35];
spectra_param.freqlimits = [20 40];


%%--------------
inputDir = fullfile(baseDir, inputTag);
outputDir = fullfile(baseDir, outputTag);
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

[inputFilename, id] = get_fileinfo(inputDir, fileExtension, prefixPosition);

rmChans = {'HEOL', 'HEOR', 'HEOG', 'HEO', ...
           'VEOD', 'VEO', 'VEOU', 'VEOG', ...
           'M1', 'M2', 'TP9', 'TP10'};

for i = 102:numel(id)
    
    fprintf('dataset %i/%i: %s\n', i, numel(id), id{i});
    outputFilename = sprintf('%s_%s.mat', id{i}, outputTag);
    outputFilenameFull = fullfile(outputDir, outputFilename);
    if exist(outputFilenameFull, 'file')
        warning('files alrealy exist!')
        continue
    end
    ica = struct();
    if strcmp(offlineRef, 'average')
        isavg = 1;
    else
        isavg = 0;
    end
    % import dataset
    [EEG, ALLEEG, CURRENTSET] = import_data(inputDir, inputFilename{i});
    
    % high pass filtering
    if exist('hipass', 'var') && ~isempty(hipass)
        EEG = pop_eegfiltnew(EEG, hipass, 0);
        EEG = eeg_checkset(EEG);
    end
    
    % low pass filtering
    if exist('lowpass', 'var') && ~isempty(lowpass)
        EEG = pop_eegfiltnew(EEG, 0, lowpass);
        EEG = eeg_checkset(EEG);
    end
    
    % add channel locations
    EEG = add_chanloc(EEG, brainTemplate, onlineRef, appendOnlineRef);
    
    % remove channels
    if ~isavg
        rmChansReal = setdiff(rmChans, offlineRef);
    else
        rmChansReal = rmChans;
    end
    
    EEG = pop_select(EEG, 'nochannel', rmChansReal);
    EEG = eeg_checkset(EEG);
    
    labels = {EEG.chanlocs.labels};
    % re-reference if necessary
    if ~isavg
        offlineRefReal = intersect(labels, offlineRef);
        if strcmpi(char(offlineRefReal), 'm2')
            indexM2 = find(ismember(labels, offlineRefReal));
            EEG.data(indexM2, :) = EEG.data(indexM2, :)/2;
        end
        EEG = pop_reref(EEG, find(ismember(labels, offlineRefReal)));
        EEG = eeg_checkset(EEG);
    else
        EEG = pop_reref(EEG, []);
        EEG = eeg_checkset(EEG);
    end

    orig_chanlocs = EEG.chanlocs;
    % reject bad channels
    % badChannels = eeg_detect_bad_channels(EEG);
    EEG = rej_badchan(EEG, flatline, mincorr, linenoisy);
    if isfield(EEG.etc, 'clean_channel_mask')
        badchans = {orig_chanlocs.labels};
        badchans = badchans(~EEG.etc.clean_channel_mask);
    else
        badchans = {};
    end
    try
        fprintf('%i number of bad channels are detected\n They are %s\n', ...
                numel(badchans), cellstrcat(badchans, ' '));
    catch
        fprintf('no bad channels detected\n');
    end
    % labels = {EEG.chanlocs.labels};
    % badchans = labels(badChannels);
    % EEG = pop_select(EEG, 'nochannel', badChannels);
    
    % re-reference if offRef is average
    if isavg
        EEG = pop_reref(EEG, []);
        EEG = eeg_checkset(EEG);
    end

    % epoching
    EEG = pop_epoch(EEG, natsort(marks), timeRange, 'epochinfo', 'yes');
    EEG = eeg_checkset(EEG);
    
    % baseline-zero
    EEG = pop_rmbase(EEG, []);

    % down-sampling
    EEG = pop_resample(EEG, sampleRate);
    EEG = eeg_checkset(EEG);
    
    % reject epochs
    [EEG, info] = rej_epoch_auto(EEG, thresh_param, trends_param, spectra_param, ...
                                 thresh_chan, reject);
    
    % run ica
    [ica.icawinv, ica.icasphere, ica.icaweights] = run_binica(EEG, isavg);
    ica.info = info;
    ica.info.badchans = badchans;
    ica.info.orig_chanlocs = orig_chanlocs;
    parsave(outputFilenameFull, ica);
    EEG = []; ALLEEG = []; CURRENTSET = [];
    
end
% eeglab redraw;
