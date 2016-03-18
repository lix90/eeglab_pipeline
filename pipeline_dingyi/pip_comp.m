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
tags = {'rest', 'task1', 'task2', 'task3'};
marks = {'1', '4', '5', '6'};
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
    out = struct();
    name = strcat(ID{i}, '_spec.mat');
    fprintf('Loading (%i/%i %s)\n', i, nFile, fileName{i});
    % loading
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    [ALLEEG EEG CURRENTSET = eeg_store(ALLEEG, EEG, 0);
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
     % epoch
     tags = {'rest', 'task1', 'task2', 'task3'};
     marks = {'1', '4', '5', '6'};
     for itag = 1:numel(tags)
         fprintf('spectral analysis of %s\n', tags{itag});
         outName = fullfile(outputDir, strcat(tags{itag}, '_', name));
         if itag == 1 % rest
             EEG = pop_epoch(EEG, marks{itag}, ...
                             [restDuration-restLength, restDuration]);
             EEG = eeg_checkset(EEG);
         else
             EEG = pop_epoch(EEG, marks{itag}, ...
                             [0+cut, duration(itag, i)-cut]);
         end
         [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, itag, 'gui', 'off');
         EEG = eeg_checkset(EEG);
         EEG = pop_rmbase(EEG, []);
         [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, itag, 'gui', 'off');
         [out.spec, out.freq, ~, ~, ~] = spectopo(EEG.data, 0, EEG.srate, ...
                                                  'plot', 'off');
         parsave(outName, out);
         [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, itag, 'retrieve', 1);
     end
     EEG = []; ALLEEG = []; CURRENTSET = 0;
end
