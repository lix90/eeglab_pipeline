clear, clc, close all;
% set directory
baseDir = '~/Data/moodPain_final/';
inputDir = fullfile(baseDir, 'spherical_rv15');
outputDir = fullfile(baseDir, 'spherical_rv100');
% dipfit parameters
RV = 1;
MODEL = 'Spherical'; % 'MNI' or 'Spherical'
poolsize = 8;
rv = 100;

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
% TRANS = [ 13.4299, 0.746361, -0.654923, 0.000878113, -0.0818352, ...
%           0.0023747, 0.852832, 0.941595, 0.85887 ];
% MNI
% locFile = 'standard_1005.elc';
% hdmfile = 'standard_vol.mat';
% mrifile = 'standard_mri.mat';
% chanfile = 'standard_1005.elc';

% prepare datasets
if ~exist(inputDir, 'dir'); disp('inputDir does not exist'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
tmp = dir(fullfile(inputDir, '*.set'));
fileName = {tmp.name};
nFile = numel(fileName);
ID = get_prefix(fileName, 1);
ID = unique(ID);

% Open matlab pool
if matlabpool('size') ~= poolsize
    matlabpool('local', poolsize)
end

parfor i = 1:nFile
    % prepare output filename
    name = strcat(ID{i}, sprintf('_dipfit_rv%i.set', rv));
    outName = fullfile(outputDir, name);
    % check if file exists
    if exist(outName, 'file'); warning('files already exist'); continue; end
    fprintf('Loading (%i/%i %s)\n', i, nFile, fileName{i});
    % load dataset
    ALLEEG = [];
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset(EEG);
    nbcomp = size(EEG.icaweights, 1);
    % nbchan = size(EEG.data, 1);
    % EEG = pop_dipfit_settings(EEG, ...
    %                           'hdmfile', hdmfileDir,...
    %                           'coordformat', MODEL,...
    %                           'mrifile', mrifileDir,...
    %                           'chanfile', chanfileDir,...
    %                           'chansel',[1:nbchan]);
    % EEG = pop_dipfit_gridsearch(EEG, ...
    %                             [1:nbcomp] ,...
    %                             [-85:17:85] ,[-85:17:85] ,[0:17:85], ...
    %                             RV);
    % EEG = eeg_checkset(EEG);
    % EEG = pop_multifit( EEG, [1:nbcomp] , ...
    %                     'threshold', RV*100, ...
    %                     'plotopt', {'normlen' 'on'});
    % EEG = eeg_checkset(EEG);
    % identify outside dipoles and dipoles rv above 20%
    selectedICs = eeg_dipselect(EEG, 100, 'inbrain', 1);
    goodICs = zeros(1, nbcomp);
    goodICs(selectedICs) = 1;
    EEG.reject.gcompreject = ~goodICs;
    EEG.setname = strcat(ID{i}, sprintf('_dipfit_rv%i', rv));
    EEG = pop_saveset(EEG, 'filename', outName); % save set
    EEG = eeg_checkset(EEG);
    EEG = [];
end
