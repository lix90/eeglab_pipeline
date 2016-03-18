%% script for computing power
% 7. remove artifactual ICs (and compute pvaf of left ICs)
% 8. epoch into 4 epoches
% 9. frequency analysis (get relative power of rhythm activity)

clear, clc, close all;
% set directory
baseDir = '~/Data/dingyi/';
inputDir = fullfile(baseDir, 'interp_noRemoveWindows_1hz');
outputDir = fullfile(baseDir, 'spec_noRemoveWindows_1hz');
marksDir = fullfile(baseDir, 'marks');
poolsize = 4;
restLength = 30;
cut = 2;
tags = {'rest', 'task1', 'task2', 'task3'};
marks = {'2', '4', '5', '6'};

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
load(strcat(marksDir, filesep, 'chanlocs.mat'));
ALLEEG = []; EEG = [];
% eeglab
for i = 1:nFile
    restDuration = duration(1, i);
    % if restDuration < restLength;
    %     disp('resting time is too short');
    %     continue;
    % end
    pvafOut = struct();
    out = struct();
    name = strcat(ID{i}, '_spec.mat');
    outNamePvaf = fullfile(outputDir, strcat('pvaf_', name));
    % outNameChanlocs = fullfile(outputDir, 'chanlocs.mat');
    fprintf('Loading (%i/%i %s)\n', i, nFile, fileName{i});
    % loading
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    EEG = eeg_checkset(EEG);
    % epoch
    latency = round([EEG.event.latency]/EEG.srate);
    if numel(latency)==6
        latency = [0 latency];
    end
    ilatency = [2 4 5 6 7];
    for itag = 1:numel(tags)
        fprintf('spectral analysis of %s\n', tags{itag});
        outName = fullfile(outputDir, strcat(tags{itag}, '_', name));
        if exist(outName, 'file'); continue; end
        if itag == 1 % rest
            EEG = pop_epoch(EEG, marks(itag), ...
                            [-(restDuration+cut), -cut]);
            EEG = eeg_checkset(EEG);
        else
            EEG = pop_epoch(EEG, marks(itag), ...
                            [0, latency(ilatency(itag+1))-latency(ilatency(itag))-cut]);
        end
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, itag, 'gui', 'off');
        EEG = eeg_checkset(EEG);
        EEG = pop_rmbase(EEG, []);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, itag, 'gui', ...
                                             'off');
        try
            [out.spec, out.freq, ~, ~, ~] = spectopo(EEG.data, 0, EEG.srate, ...
                                                     'plot', 'off');
            parsave(outName, out);
        catch
            fprintf('error happen in %s of %s\n', tags{itag}, fileName{i});
            continue
        end
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, itag, 'retrieve', 1);
    end
    EEG = []; ALLEEG = []; CURRENTSET = 0;
end
eeglab redraw
