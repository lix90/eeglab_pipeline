clear, clc, close all
baseDir = '~/Data/gender-role-emotion-regulation/';
inputTag = 'merge';
outputTag = 'preEpoch3';
icaTag = 'preICA3';
fileExtension = {'set', 'eeg'};
prefixPosition = 1;

brainTemplate = 'Spherical';
onlineRef = 'FCz';
appendOnlineRef = true;
offlineRef = {'TP9', 'TP10', 'M2'};
sampleRate = 250;

marks = {'S 11', 'S 22', 'S 33', 'S 44', 'S 55'};
timeRange = [-1, 5];
hipass = 0.02;
lowpass = [];

thresh_param.low_thresh = -300;
thresh_param.up_thresh = 300;
trends_param.slope = 200;
trends_param.r2 = 0.3;
spectra_param.threshold = [-35, 35];
spectra_param.freqlimits = [20 40];
joint_param.single_chan = 8;
joint_param.all_chan = 4;
kurt_param.single_chan = 8;
kurt_param.all_chan = 4;
thresh_chan = 0.1;
reject = 1;

EOG = [];
rejIC = 0;

%%--------------
inputDir = fullfile(baseDir, inputTag);
outputDir = fullfile(baseDir, outputTag);
icaDir = fullfile(baseDir, icaTag);
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

[inputFilename, id] = get_fileinfo(inputDir, fileExtension, prefixPosition);

rmChans = {'HEOL', 'HEOR', 'HEOG', 'HEO', ...
           'VEOD', 'VEO', 'VEOU', 'VEOG', ...
           'M1', 'M2', 'TP9', 'TP10'};

for i =102:numel(id)

    fprintf('subj %i/%i: %s', i, numel(id), id{i});
    outputFilename = sprintf('%s_%s.set', id{i}, outputTag);
    outputFilenameFull = fullfile(outputDir, outputFilename);
    
    if exist(outputFilenameFull, 'file')
        warning('files alrealy exist!')
        continue
    end

    % load icamat
    icaFile = sprintf('%s_%s.mat', id{i}, icaTag);
    data = parload(fullfile(icaDir, icaFile));
        
    % import dataset
    [EEG, ALLEEG, CURRENTSET] = import_data(inputDir, inputFilename{i});
    
    % add channel locations
EEG = add_chanloc(EEG, brainTemplate, onlineRef, appendOnlineRef);
    
% remove channels
if ~strcmp(offlineRef, 'average')
    rmChansReal = setdiff(rmChans, offlineRef);
else
    rmChansReal = rmChans;
end
    
EEG = pop_select(EEG, 'nochannel', rmChansReal);
EEG = eeg_checkset(EEG);
    
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
    
% high pass filtering
if ~isempty(hipass)
    EEG = pop_eegfiltnew(EEG, hipass, 0);
    EEG = eeg_checkset(EEG);
end
    
if ~isempty(lowpass)
    EEG = pop_eegfiltnew(EEG, 0, lowpass);
    EEG = eeg_checkset(EEG);
end
    
% reject bad channels
labels = {EEG.chanlocs.labels};
ica = data.ica;
badchans = union(ica.info.rej_chan_by_epoch, ica.info.badchans);
EEG = pop_select(EEG, 'nochannel', find(ismember(labels, badchans)));
    
% re-reference if offRef is average
if strcmp(offlineRef, 'average')
    EEG = pop_reref(EEG, []);
    EEG = eeg_checkset(EEG);
end

% epoching
EEG = pop_epoch(EEG, natsort(marks), timeRange, 'epochinfo', 'yes');
EEG = eeg_checkset(EEG);

% down-sampling
EEG = pop_resample(EEG, sampleRate);
EEG = eeg_checkset(EEG);
    
% baseline-zero
EEG = pop_rmbase(EEG, []);
EEG = eeg_checkset(EEG);

% reject epochs
EEG = pop_rejepoch(EEG, ica.info.rej_epoch_auto, 0);
EEG = eeg_checkset(EEG);
    
EEG.etc.info = ica.info;
EEG.icawinv = ica.icawinv;
EEG.icasphere = ica.icasphere;
EEG.icaweights = ica.icaweights;
EEG = eeg_checkset(EEG, 'ica');
    
% %% reject ICs
% EEG = rej_SASICA(EEG, EOG, rejIC);

% % baseline-zero again
% if rejIC
%     EEG = pop_rmbase(EEG, []);
% end
    
EEG = pop_saveset(EEG, 'filename', outputFilenameFull);
EEG = []; ALLEEG = []; CURRENTSET = [];
end
