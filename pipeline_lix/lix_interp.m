clear, clc, close all;
% set directory
<<<<<<< HEAD
baseDir = '~/Data/moodPain_final/';
inputDir = fullfile(baseDir, 'spherical_rv100');
outputDir = fullfile(baseDir, 'interp_rv100');
=======
baseDir = '~/Data/dingyi/';
inputDir = fullfile(baseDir, 'ica');
outputDir = fullfile(baseDir, 'interp');
>>>>>>> 62f55619d9928185f74e195cc4bb804e902dcc0a
chanlocsDir = '~/chanlocs.mat';

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

<<<<<<< HEAD
    outName = fullfile(outputDir, strcat(ID{i}, '_interp_rv15.set'));
=======
    outName = fullfile(outputDir, strcat(ID{i}, '_interp.set'));
>>>>>>> 62f55619d9928185f74e195cc4bb804e902dcc0a
    if exist(outName, 'file'); continue; end
    fprintf('Loading (%i/%i %s)\n', i, nFile, fileName{i});
    % loading data
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset(EEG);
    % remove artfactual ICs
<<<<<<< HEAD
    EEG = pop_subcomp(EEG, [], 0);
=======
    EEG = pop_subcomp(EEG, find(EEG.reject.gcompreject), 0);
>>>>>>> 62f55619d9928185f74e195cc4bb804e902dcc0a
    EEG = eeg_checkset(EEG);
    % interpolating channels
    EEG = eeg_interp(EEG, chanlocs, 'spherical');
    EEG = eeg_checkset(EEG);
    EEG = pop_saveset(EEG, outName);
    EEG = []; ALLEEG = [];

end
<<<<<<< HEAD
=======

>>>>>>> 62f55619d9928185f74e195cc4bb804e902dcc0a
