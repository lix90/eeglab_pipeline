clear, clc, close all
baseDir = '~/Data/gender-role-emotion-regulation/';
inputTag = 'preEpoch3';
outputTag = 'outErp3';
fileExtension = 'set';
prefixPosition = 1;
chanlocDir = '~/chanlocs_er_60n.mat';

marks = {'S 11', 'S 22', 'S 33', 'S 44', 'S 55'};
timeRange = [-0.2, 4];
lowpass = 30;
erp_average = 1;

thresh_param.low_thresh = -80;
thresh_param.up_thresh = 80;
load(chanlocDir);

%%--------------
inputDir = fullfile(baseDir, inputTag);
outputDir = fullfile(baseDir, outputTag);
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

[inputFilename, id] = get_fileinfo(inputDir, fileExtension, prefixPosition);

erp = struct();
outputFilename = sprintf('%s.mat', outputTag);
outputFilenameFull = fullfile(outputDir, outputFilename);
if exist(outputFilenameFull, 'file')
    warning('files alrealy exist!');
    return
end

for i_s = 1:numel(id)

    fprintf('subj %i/%i: %s', i_s, numel(id), id{i_s});
    % import dataset
    [EEG, ALLEEG, CURRENTSET] = import_data(inputDir, inputFilename{i_s});
    % remove bad ICs
    EEG = pop_subcomp(EEG, [], 0);
    EEG = eeg_checkset(EEG);
    % interpolate channels
    EEG = pop_interp(EEG, chanlocs, 'spherical');
    EEG = eeg_checkset(EEG);
    % low pass filtering
    if ~isempty(lowpass)
        EEG = pop_eegfiltnew(EEG, 0, lowpass);
        EEG = eeg_checkset(EEG);
    end
    % [EEG, ~] = rej_epoch_auto(EEG, thresh_param, [], [] , [], [], 1, 1);
    % epoching
    if all(ismember(marks, {EEG.epoch.eventtype}))
        for i_v = 1:numel(marks)
            EEG_epoch = pop_epoch(EEG, marks(i_v), timeRange, ...
                                  'epochinfo', 'yes');
            EEG_epoch = eeg_checkset(EEG_epoch);
            EEG_epoch = pop_rmbase(EEG_epoch, timeRange);
            if erp_average
                erp(i_s, i_v).data = squeeze(mean(EEG_epoch.data, 3));
            else
                erp(i_s, i_v).data = EEG_epoch.data;
            end
            erp(i_s, i_v).id = id{i_s};
            erp(i_s, i_v).srate = EEG_epoch.srate;
            erp(i_s, i_v).trials = EEG_epoch.trials;
            erp(i_s, i_v).nbchan = EEG_epoch.nbchan;
            erp(i_s, i_v).pnts = EEG_epoch.pnts;
            erp(i_s, i_v).xmin = EEG_epoch.xmin;
            erp(i_s, i_v).xmax = EEG_epoch.xmax;
            erp(i_s, i_v).times = EEG_epoch.times;
            erp(i_s, i_v).chanlocs = EEG_epoch.chanlocs;
            erp(i_s, i_v).event = marks(i_v);
        end
    else
        continue
    end
    EEG = []; ALLEEG = []; CURRENTSET = [];
end
parsave2(outputFilenameFull, erp, 'erp', '-mat');
