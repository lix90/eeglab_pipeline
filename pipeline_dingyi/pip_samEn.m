%% script for computing power
% 7. remove artifactual ICs (and compute pvaf of left ICs)
% 8. epoch into 4 epoches
% 9. frequency analysis (get relative power of rhythm activity)

clear, clc, close all;
% set directory
baseDir = '~/Data/dingyi/';
inputDir = fullfile(baseDir, 'interp_noRemoveWindows_1hz');
outputDir = fullfile(baseDir, 'samEn_noRemoveWindows_1hz');

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

ALLEEG = []; EEG = [];

for i = 1:nFile

    name = strcat(ID{i}, '_samEn.mat');
    if exist(fullfile(inputDir, name), 'file'); continue; end
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
    restDuration = latency(2)-latency(1)-2;
    if restDuration<restLength
        continue
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
            out = lix_samEn(EEG);
            save(outName, 'out');
        catch
            fprintf('error happen in %s of %s\n', tags{itag}, fileName{i});
            continue
        end
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, itag, 'retrieve', 1);
    end
    EEG = []; ALLEEG = []; CURRENTSET = 0;
end
% eeglab redraw
