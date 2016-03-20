%% script for interpotating
% 7. remove artifactual ICs (and compute pvaf of left ICs)
% 8. epoch into 4 epoches
% 9. frequency analysis (get relative power of rhythm activity)
clear, clc, close all;
% set directory
baseDir = '~/Data/dingyi/';
inputDir = fullfile(baseDir, 'ica');
outputDir = fullfile(baseDir, 'interp');
poolsize = 4;

%% -----------------------------------------------------------
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

for i = 1:nFile

    outName = fullfile(outputDir, strcat(ID{i}, '_interp.set'));
    if exist(outName, 'file'); continue; end
    fprintf('Loading (%i/%i %s)\n', i, nFile, fileName{i});
    % loading data
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset(EEG);
    % remove artfactual ICs
    EEG = pop_subcomp(EEG, find(EEG.reject.gcompreject), 0);
    EEG = eeg_checkset(EEG);
    % interpolating channels
    EEG = eeg_interp(EEG, EEG.etc.origchanlocs, 'spherical');
    EEG = eeg_checkset(EEG);
    EEG = pop_saveset(EEG, outName);
    EEG = []; ALLEEG = [];

end

