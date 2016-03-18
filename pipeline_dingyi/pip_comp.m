%% script for computing power
% 7. remove artifactual ICs (and compute pvaf of left ICs)
% 8. epoch into 4 epoches
% 9. frequency analysis (get relative power of rhythm activity)

clear, clc, close all;
% set directory
baseDir = '~/Data/dingyi/';
inputDir = fullfile(baseDir, 'ica_noRemoveWindows_1hz');
outputDir = fullfile(baseDir, 'spec_noRemoveWindows_1hz');
marksDir = fullfile(baseDir, 'marks');
poolsize = 4;
restLength = 30;
cut = 0;
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
% Open matlab pool
% if matlabpool('size') < poolsize
%     matlabpool('local', poolsize)
% end
load(strcat(marksDir, filesep, 'duration.mat'));

for i = 1:1
    restDuration = duration(1, i);
    if restDuration < restLength; disp('resting time is too short'); continue; ...
    end
    pvafOut = struct();
    rest = struct();
    task1 = struct();
    task2 = task1;
    task3 = task1;
    name = strcat(ID{i}, '_spec.mat');
    outNameRest = fullfile(outputDir, strcat('rest_', name));
    outNameTask1 = fullfile(outputDir, strcat('task1_', name));
    outNameTask2 = fullfile(outputDir, strcat('task2_', name));
    outNameTask3 = fullfile(outputDir, strcat('task3_', name));
    outNamePvaf = fullfile(outputDir, strcat('pvaf_', name));
    % check if file exists
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
    pvafOut.pvaf = pvaf;
    pvafOut.pvafs = pvafs;
    pvafOut.vars = vars;
    parsave(outNamePvaf, pvafOut);
    % remove artfactual ICs
    EEG = pop_subcomp(EEG, find(EEG.reject.gcompreject), 0);
    EEG = eeg_checkset(EEG);
    % interpolate bad channels
    power.chanlocs = EEG.etc.origchanlocs;
    EEG = eeg_interp(EEG, EEG.etc.origchanlocs, 'spherical');
    EEG = eeg_checkset(EEG);
    % epoch 1: rest
    % try
    disp('spectral analysis of rest')
    EEGrest = pop_epoch(EEG, {'1'}, [restDuration-restLength, restDuration]);
    EEGrest = eeg_checkset(EEGrest);
    [rest.spec, rest.freq, ~, ~, ~] = spectopo(EEGrest.data, 0, EEGrest.srate);
    parsave(outNameRest, rest);
    % catch
    %     continue
    % end
    % epoch 2: task 1
    % try
    disp('spectral analysis of task 1')
    EEGtask1 = pop_epoch(EEG, {'4'}, [0+cut, duration(2, i)-cut]); % 5
    EEGtask1 = eeg_checkset(EEGtask1);
    [task1.spec, task1.freq, ~, ~, ~] = spectopo(EEGtask1.data, 0, EEGtask1.srate);
    parsave(outNameTask1, task1);
    % catch
    %     continue
    % end
    % try
    % epoch 3: task 2
    disp('spectral analysis of task 2')
    EEGtask2 = pop_epoch(EEG, {'5'}, [0+cut, duration(3, i)-cut]); % 6
    EEGtask2 = eeg_checkset(EEGtask2);
    [task2.spec, task2.freq, ~, ~, ~] = spectopo(EEGtask2.data, 0, EEGtask2.srate);
    parsave(outNameTask2, task2);
    % catch
    %     continue
    % end
    % try
    % epoch 4: task 3
    disp('spectral analysis of task 3')
    EEGtask3 = pop_epoch(EEG, {'6'}, [0+cut, duration(4, i)-cut]); % 7
    EEGtask3 = eeg_checkset(EEGtask3);
    [task3.spec, task3.freq, ~, ~, ~] = spectopo(EEGtask3.data, 0, EEGtask3.srate);
    parsave(outNameTask3, task3);
    % catch
    %     continue
    % end
    EEG = [];

end
