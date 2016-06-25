%% script for computing power
% 7. remove artifactual ICs (and compute pvaf of left ICs)
% 8. epoch into 4 epoches
% 9. frequency analysis (get relative power of rhythm activity)

clear, clc, close all;

% set directory
baseDir = '~/Data/dingyi/';
inputDir = fullfile(baseDir, 'ica_noRemoveWindows_1hz');
outputDir = fullfile(baseDir, 'power_noRemoveWindows_1hz');
marksDir = fullfile(baseDir, 'marks');
poolsize = 2;
restLength = 30;
eeglabDir = fileparts(which('eeglab.m'));
addpath(genpath(eeglabDir));

% prepare datasets
if ~exist(inputDir, 'dir'); disp('inputDir does not exist'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
tmp = dir(fullfile(inputDir, '*.set'));
fileName = {tmp.name};
nFile = numel(fileName);
ID = get_prefix(fileName, 1);
ID = unique(ID);
load(strcat(marksDir, filesep, 'duration.mat'));

% Open matlab pool
% if matlabpool('size') < poolsize
%     matlabpool('local', poolsize)
% end

for i = 9:nFile
    restDuration = duration(1, i);
    if restDuration < restLength; disp('resting time is too short'); continue; ...
    end
    pvafOut = struct();
    name = strcat(ID{i}, '_power.mat');
    outNameRest = fullfile(outputDir, strcat('rest_', name));
    outNameTask1 = fullfile(outputDir, strcat('task1_', name));
    outNameTask2 = fullfile(outputDir, strcat('task2_', name));
    outNameTask3 = fullfile(outputDir, strcat('task3_', name));
    outNamePvaf = fullfile(outputDir, strcat('pvaf_', name));
    % check if file exists
    % if exist(outName, 'file'); warning('files already exist'); continue; end
    fprintf('Loading (%i/%i %s)\n', i, nFile, fileName{i});
    % loading
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset(EEG);
    info = struct('converted_sample_frequency', EEG.srate);
    % compute pvafs
    if isempty(EEG.icaact)
        EEG.icaact = eeg_getdatact(EEG, ...
                                   'component', 1:size(EEG.icaweights, 1));
    end
    [pvaf, pvafs, vars] = eeg_pvaf(EEG, find(~EEG.reject.gcompreject), 'plot', 'off');
    pvafOut.pvaf = pvaf;
    pvafOut.pvafs = pvafs;
    pvafOut.vars = vars;
    parsave(outNamePvaf, pvafOut);
    % remove artfactual ICs
    EEG = pop_subcomp(EEG, find(EEG.reject.gcompreject), 0);
    EEG = eeg_checkset(EEG);
    % interpolate bad channels
    EEG = eeg_interp(EEG, EEG.etc.origchanlocs, 'spherical');
    EEG = eeg_checkset(EEG);
    % epoch 1: rest
    EEGrest = pop_epoch(EEG, {'1'}, [restDuration-restLength, restDuration]);
    EEGrest = eeg_checkset(EEGrest);
    EEGrest = pop_rmbase(EEGrest, []);
    PeakFitRest = lix_nbt_doPeakFit(EEGrest.data', info);
    disp('spectral analysis of rest')
    parsave(outNameRest, PeakFitRest);

    % epoch 2: task 1
    EEGtask1 = pop_epoch(EEG, {'4'}, [0, duration(2, i)]); % 5
    EEGtask1 = eeg_checkset(EEGtask1);
    EEGtask1 = pop_rmbase(EEGtask1, []);
    PeakFitTask1 = lix_nbt_doPeakFit(EEGtask1.data', info);
    disp('spectral analysis of task 1')
    parsave(outNameTask1, PeakFitTask1);

    % epoch 3: task 2
    EEGtask2 = pop_epoch(EEG, {'5'}, [0, duration(3, i)]); % 6
    EEGtask2 = eeg_checkset(EEGtask2);
    EEGtask2 = pop_rmbase(EEGtask2, []);
    PeakFitTask2 = lix_nbt_doPeakFit(EEGtask2.data', info);
    disp('spectral analysis of task 2')
    parsave(outNameTask2, PeakFitTask2);

    % epoch 4: task 3
    EEGtask3 = pop_epoch(EEG, {'6'}, [0, duration(4, i)]); % 7
    EEGtask3 = eeg_checkset(EEGtask3);
    EEGtask3 = pop_rmbase(EEGtask3, []);
    PeakFitTask3 = lix_nbt_doPeakFit(EEGtask3.data', info);
    disp('spectral analysis of task 3')
    parsave(outNameTask3, PeakFitTask3);

    EEG = [];
end
