clear, clc, close all
baseDir = '~/Data/lqs_gambling/';
inputTag = 'rest_merge';
outputTag = 'rest_preICA';
fileExtension = {'set'};
prefixPosition = 2;

brainTemplate = 'Spherical';
onlineRef = 'FCz';
appendOnlineRef = 0;
% offlineRef = {'TP9', 'TP10'};
offlineRef = 'rest';

sampleRate = 250;
hipass = 1;
lowpass = [];
marks = {'no_neg_big'  'no_neg_small'  'no_pos_big'  'no_pos_small'...
         'yes_neg_big'  'yes_neg_mall'  'yes_pos_big'  'yes_pos_small'  };
timeRange = [-1, 2];

flatline = 5;
mincorr = 0.4;
linenoisy = 4;

thresh_chan = 0.05;
reject = 1;
thresh_param.low_thresh = -300;
thresh_param.up_thresh = 300;
trends_param.slope = 200;
trends_param.r2 = 0.2;
joint_param.single_chan = 8;
joint_param.all_chan = 4;
kurt_param.single_chan = 8;
kurt_param.all_chan = 4;
spectra_param.threshold = [-35, 35];
spectra_param.freqlimits = [20 40];

%%--------------
inputDir = fullfile(baseDir, inputTag);
outputDir = fullfile(baseDir, outputTag);
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

[inputFilename, id] = get_fileinfo(inputDir, fileExtension, prefixPosition);

rmChans = {'HEOL', 'HEOR', 'HEOG', 'HEO', ...
           'VEOD', 'VEO', 'VEOU', 'VEOG', ...
           'M1', 'M2', 'TP9', 'TP10', ...
           'CB1', 'CB2'};
for i = 1:numel(id)
    
    fprintf('subject %i/%i: %s\n', i, numel(id), id{i});
    outputFilename = sprintf('%s_%s.mat', id{i}, outputTag);
    outputFilenameFull = fullfile(outputDir, outputFilename);
    if exist(outputFilenameFull, 'file')
        warning('files alrealy exist!')
        continue
    end
    ica = struct();
    
    % import dataset
    [EEG, ALLEEG, CURRENTSET] = import_data(inputDir, inputFilename{i});
    
    % high pass filtering
    EEG = pop_eegfiltnew(EEG, hipass, 0);
    EEG = eeg_checkset(EEG);
    
    % low pass filtering
    if ~isempty(lowpass)
        EEG = pop_eegfiltnew(EEG, 0, lowpass);
        EEG = eeg_checkset(EEG);
    end
    
    % add channel locations
    EEG = add_chanloc(EEG, brainTemplate, onlineRef, appendOnlineRef); 
    % EEG = pop_chanedit(EEG, 'lookup', chanLocDir); % add channel location
    EEG = eeg_checkset(EEG);
    
    % remove channels
    if ~strcmp(offlineRef, 'average')
        rmChansReal = setdiff(rmChans, offlineRef);
    else
        rmChansReal = rmChans;
    end
    
    EEG = pop_select(EEG, 'nochannel', rmChansReal);
    EEG = eeg_checkset(EEG);
    
    % labels = {EEG.chanlocs.labels};
    % % re-reference if necessary
    % if ~strcmp(offlineRef, 'average')
    %     offlineRefReal = intersect(labels, offlineRef);
    %     EEG = pop_reref(EEG, find(ismember(labels, offlineRefReal)));
    %     EEG = eeg_checkset(EEG);
    % elseif strcmp(offlineRef, 'average')
    %     EEG = pop_reref(EEG, []);
    %     EEG = eeg_checkset(EEG);
    % elseif isempty(offlineRef)
    %     disp('not to be re-referenced')
    % end

    orig_chanlocs = EEG.chanlocs;
    % reject bad channels
    % badChannels = eeg_detect_bad_channels(EEG);
    EEG = rej_badchan(EEG, flatline, mincorr, linenoisy);
    badchans = {orig_chanlocs.labels};
    if ~isfield(EEG.etc, 'clean_channel_mask')
        EEG.etc.clean_channel_mask = ones(1, EEG.nbchan);
    end
    badchans = badchans(~EEG.etc.clean_channel_mask);
    % labels = {EEG.chanlocs.labels};
    % badchans = labels(badChannels);
    % EEG = pop_select(EEG, 'nochannel', badChannels);
    
    % re-reference if offRef is average
    % if strcmp(offlineRef, 'average')
    %     EEG = pop_reref(EEG, []);
    %     EEG = eeg_checkset(EEG);
    % end

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
                                 joint_param, kurt_param, thresh_chan, reject);
    
    % run ica
    if strcmp(offlineRef, 'average')
        isavg = 1;
    else
        isavg = 0;
    end
    [ica.icawinv, ica.icasphere, ica.icaweights] = run_binica(EEG, isavg);
    ica.info = info;
    ica.info.badchans = badchans;
    ica.info.orig_chanlocs = orig_chanlocs;
    parsave2(outputFilenameFull, ica, 'ica', '-mat');
    EEG = []; ALLEEG = []; CURRENTSET = [];
    
end
