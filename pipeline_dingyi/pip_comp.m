%% script for computing power
% 7. remove artifactual ICs (and compute pvaf of left ICs)
% 8. epoch into 4 epoches
% 9. frequency analysis (get relative power of rhythm activity)

clear, clc, close all;
% set directory
baseDir = '~/data/dingyi/';
inputDir = fullfile(baseDir, 'ica');
outputDir = fullfile(baseDir, 'power');
marksDir = fullfile(baseDir, 'marks');
poolsize = 2;
% prepare datasets
if ~exist(inputDir, 'dir'); disp('inputDir does not exist'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
tmp = dir(fullfile(inputDir, '*.set'));
fileName = {tmp.name};
nFile = numel(fileName);
ID = get_prefix(fileName, 1);
ID = unique(ID);
% Open matlab pool
% if matlabpool('size') < poolsize
%     matlabpool('local', poolsize)
% end
load(strcat(marksDir, filesep, 'taskduration.mat'));
duration = x;

for i = 1:nFile
    
    power = struct();
    name = strcat(ID{i}, '_power.mat');
    outName = fullfile(outputDir, name);
    % check if file exists
    if exist(outName, 'file'); warning('files already exist'); continue; end
    fprintf('Loading (%i/%i %s)\n', i, nFile, fileName{i});
    % loading
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset(EEG);
    % compute pvafs
    if isempty(EEG.icaact)
        EEG.icaact = eeg_getdatact(EEG, ...
                                   'component', 1:size(EEG.icaweights, 1));
    end
    [pvaf, pvafs, vars] = eeg_pvaf(EEG, find(~EEG.reject.gcompreject), 'plot', 'off');
    power.pvaf = pvaf;
    power.pvafs = pvafs;
    power.vars = vars;
    % remove artfactual ICs
    EEG = pop_subcomp(EEG, find(EEG.reject.gcompreject), 0);
    EEG = eeg_checkset(EEG);
    % interpolate bad channels
    power.chanlocs = EEG.etc.origchanlocs;
    EEG = eeg_interp(EEG, EEG.etc.origchanlocs, 'spherical');
    EEG = eeg_checkset(EEG);
    % epoch 1: rest
    disp('spectral analysis of rest')
    EEGrest = pop_epoch(EEG, {'R2'}, [-30, 0]);
    EEGrest = eeg_checkset(EEGrest);
    [specrest, freqrest, ~, ~, ~] = spectopo(EEGrest.data, 0, EEGrest.srate);
    EEGrest = [];
    % epoch 2: task 1
    disp('spectral analysis of task 1')
    EEGtask1 = pop_epoch(EEG, {'T1'}, [0, duration(1, i)]); % 5
    EEGtask1 = eeg_checkset(EEGtask1);
    [spectask1, freqtask1, ~, ~, ~] = spectopo(EEGtask1.data, 0, EEGtask1.srate);
    EEGtask1 = [];
    % epoch 3: task 2
    disp('spectral analysis of task 2')
    EEGtask2 = pop_epoch(EEG, {'T2'}, [0, duration(2, i)]); % 6
    EEGtask2 = eeg_checkset(EEGtask2);
    [spectask2, freqtask2, ~, ~, ~] = spectopo(EEGtask2.data, 0, EEGtask2.srate);
    EEGtask2 = [];
    % epoch 4: task 3
    disp('spectral analysis of task 3')
    EEGtask3 = pop_epoch(EEG, {'T3'}, [0, duration(3, i)]); % 7
    EEGtask3 = eeg_checkset(EEGtask3);
    [spectask3, freqtask3, ~, ~, ~] = spectopo(EEGtask3.data, 0, EEGtask3.srate);
    EEGtask3 = [];
    power.rest = specrest;
    power.restf = freqrest;
    power.task1 = spectask1;
    power.task2 = spectask2;
    power.task3 = spectask3;
    power.task1f = freqtask1;
    power.task2f = freqtask2;
    power.task3f = freqtask3;
    % save
    parsave(outName, power);
    EEG = [];

end