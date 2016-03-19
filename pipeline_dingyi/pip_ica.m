%% script for preprocessing before ICA
% * manually check data
% 6. ica
% * manually check data

baseDir = '~/Data/dingyi/';
inputDir = fullfile(baseDir, 'pre_noRemoveWindows_1hz');
outputDir = fullfile(baseDir, 'ica_noRemoveWindows_1hz');
poolsize = 8;
eeglabDir = fileparts(which('eeglab.m'));
addpath(genpath(eeglabDir));

if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
tmp = dir(fullfile(inputDir, '*.set'));
fileName = {tmp.name};
nFile = numel(fileName);
ID = get_prefix(fileName, 1);
ID = unique(ID);

if matlabpool('size')<poolsize
    matlabpool('local', poolsize);
end

parfor i = 1:nFile
    % prepare output filename
    name = strcat(ID{i}, '_ica.set');
    outName = fullfile(outputDir, name);
    % check if file exists
    if exist(outName, 'file'); warning('files already exist'); continue; end 
    % load dataset
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset(EEG);
    % ica
    EEG = pop_runica(EEG,'extended', 1, 'interupt', 'on');
    EEG = eeg_checkset(EEG);
    EEG = pop_saveset(EEG, 'filename', outName);
    EEG = []; 
end
