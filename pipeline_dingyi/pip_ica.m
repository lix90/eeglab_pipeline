%% script for preprocessing before ICA
% * manually check data
% 6. ica
% * manually check data

baseDir = '~/data/dingyi/';
inputDir = fullfile(baseDir, 'pre');
outputDir = fullfile(baseDir, 'ica');
poolsize = 2;
RV = 1;
MODEL = 'Spherical';
eeglabDir = fullfile(fileparts(which('eeglab.m')));
addpath(genpath(eeglabDir));

%% channel location files
locFile = 'standard-10-5-cap385.elp';
hdmfile = 'standard_BESA.mat';
mrifile = 'avg152t1.mat';
chanfile = 'standard-10-5-cap385.elp';
hdmfileDir = which(hdmfile);
mrifileDir = which(mrifile);
chanfileDir = which(chanfile);
locDir = which(locFile);
if ispc
    hdmfileDir = strrep(hdmfileDir, '\', '/');
    mrifileDir = strrep(mrifileDir, '\', '/');
    chanfileDir = strrep(chanfileDir, '\', '/');
    locDir = strrep(locDir, '\', '/');
end

if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
tmp = dir(fullfile(inputDir, '*.set'));
fileName = {tmp.name};
nFile = numel(fileName);
ID = get_prefix(fileName, 1);
ID = unique(ID);

% if matlabpool('size')<poolsize
% matlabpool('local', poolsize);
% end

for i = 1 
    % prepare output filename
    name = strcat(ID{i}, '_ica.set');
    outName = fullfile(outputDir, name);
    % check if file exists
    if exist(outName, 'file'); warning('files already exist'); continue; end 
    % load dataset
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset(EEG); 
    % remove Trigger
    rmidx = find(strcmp({EEG.chanlocs.labels}, {'Trigger'}));
    EEG = pop_select(EEG, 'nochannel', rmidx);
    EEG = eeg_checkset(EEG);
    % ica
    EEG = pop_runica(EEG,'extended', 1, 'interupt', 'on');
    EEG = eeg_checkset(EEG);
    % dipfit
    nbcomp = size(EEG.icaweights, 1);
    nbchan = size(EEG.data, 1);
    EEG = pop_dipfit_settings(EEG, ...
                              'hdmfile', hdmfileDir,...
                              'coordformat', MODEL,...
                              'mrifile', mrifileDir,...
                              'chanfile', chanfileDir,...
                              'chansel',[1:nbchan]);
    EEG = pop_dipfit_gridsearch(EEG, ...
                                [1:nbcomp] ,...
                                [-85:17:85] ,[-85:17:85] ,[0:17:85], ...
                                RV);
    EEG = eeg_checkset(EEG);
    EEG = pop_multifit( EEG, [1:nbcomp] , ...
                        'threshold', RV*100, ...
                        'plotopt', {'normlen' 'on'});
    EEG = eeg_checkset(EEG);
    % identify outside dipoles and dipoles rv above 15%
    selectedICs = eeg_dipselect(EEG, 15, 'inbrain', 1);
    badICs = zeros(1, nbcomp);
    badICs(selectedICs) = 1;
    EEG.reject.gcompreject = badICs;
    EEG = pop_saveset(EEG, 'filename', outName);
    EEG = []; 
end
