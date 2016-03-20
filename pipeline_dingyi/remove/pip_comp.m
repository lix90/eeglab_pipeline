%% script for computing power
% 7. remove artifactual ICs (and compute pvaf of left ICs)
% 8. epoch into 4 epoches
% 9. frequency analysis (get relative power of rhythm activity)

clear, clc, close all;
% set directory
baseDir = '~/Data/dingyi/';
inputDir = fullfile(baseDir, 'ica');
outputDir = fullfile(baseDir, 'interp');
marksDir = fullfile(baseDir, 'marks');
poolsize = 4;

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
load(strcat(marksDir, filesep, 'chanlocs.mat'));
ALLEEG = []; EEG = [];
eeglab
for i = 1:nFile
    pvafOut = struct();
    outNamePvaf = fullfile(outputDir, strcat('pvaf_', ID{i}, '.mat'));
    outName = fullfile(outputDir, strcat(ID{i}, '_interp.set'));
    fprintf('Loading (%i/%i %s)\n', i, nFile, fileName{i});
    % loading
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    EEG = eeg_checkset(EEG);
    % compute pvafs
    if isempty(EEG.icaact)
        EEG.icaact = eeg_getdatact(EEG, ...
                                   'component', 1:size(EEG.icaweights, 1));
    end
    [pvaf, pvafs, vars] = eeg_pvaf(EEG, find(~EEG.reject.gcompreject), ...
                                   'plot', 'off');
    pvafOut.pvaf = pvaf;
    pvafOut.pvafs = pvafs;
    pvafOut.vars = vars;
    parsave(outNamePvaf, pvafOut);
    % remove artfactual ICs
    EEG = pop_subcomp(EEG, find(EEG.reject.gcompreject), 0);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'gui', 'off');
    EEG = eeg_checkset(EEG);
    % interpolate bad channels
    % chanlocs = EEG.etc.origchanlocs;
    % if i == 2
    %     parsave(outNameChanlocs, chanlocs);
    % end
    EEG = eeg_interp(EEG, y, 'spherical');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'gui', 'off');
    EEG = eeg_checkset(EEG);
    EEG = pop_saveset(EEG, outName);
    EEG = []; ALLEEG = [];
end
eeglab redraw
