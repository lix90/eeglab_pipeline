clear, clc, close all;
% set directory
baseDir = '~/Data/iris/';
inputDir = fullfile(baseDir, 'spherical_rv20');
outputDir = fullfile(baseDir, 'interp_rv20');
chanlocsDir = fullfile(baseDir, 'chanlocs.mat');

%% -----------------------------------------------------------
eeglabDir = fileparts(which('eeglab.m'));
addpath(genpath(eeglabDir));
load(chanlocsDir);

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
    EEG = pop_subcomp(EEG, [], 0);
    EEG = eeg_checkset(EEG);
    % interpolating channels
    EEG = eeg_interp(EEG, chanlocs, 'spherical');
    EEG = eeg_checkset(EEG);
    EEG = pop_saveset(EEG, outName);
    EEG = []; ALLEEG = [];

end
