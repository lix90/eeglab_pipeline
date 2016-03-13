clear, clc, close all;
% set directory
baseDir = '~/Data/yang_select';
inputDir = fullfile(baseDir, 'ica');
outputDir = fullfile(baseDir, 'spherical');
% dipfit parameters
RV = 1;
MODEL = 'Spherical'; % 'MNI' or 'Spherical'
poolsize = 4;

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
if matlabpool('size')<poolsize
    matlabpool('local', poolsize)
end

parfor i = 1:nFile
    % prepare output filename
    name = strcat(ID{i}, '_dipfit.set');
    outName = fullfile(outputDir, name);
    % check if file exists
    if exist(outName, 'file'); warning('files already exist'); continue; end
    fprintf('Loading (%i/%i %s)\n', i, nFile, fileName{i});
    % load dataset
    ALLEEG = [];
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset(EEG);
    % backup EEG
    % rmEye = find(EEG.reject.gcompreject);
    % remove artifactual components
    % EEG = pop_subcomp(EEG, rmEye, 0);
    % EEG = eeg_checkset(EEG);
    % dipfitting
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
    % dipout = dipfit_reject(EEG.dipfit.model, 0.15);
    % rmRv = [];
    % for ii = 1:nbcomp
    %     if dipout(ii).rv == 1
    %         rmRv = [rmRv ii];
    %     end
    % end
    % rmOut = [];
    % for index = 1:nbcomp
    %     if ~isempty(EEG.dipfit.model(index).posxyz)
    %         if any(sqrt(sum(EEG.dipfit.model(index).posxyz.^2,2)) > 85)
    %             rmOut = [rmOut index];
    %         end
    %     end
    % end
    % rmComps = union(rmRv, rmOut);
    badICs = zeros(1, nbcomp);
    badICs(selectedICs) = 1;
    EEG.reject.gcompreject = badICs;
    % goodICs = setdiff([1:nbcomp], rmComps);
    % get lefted percentage of data
    % if isempty(EEG.icaact)
    %    EEG.icaact = eeg_getdatact(EEG, ...
    %                               'component', 1:size(EEG.icaweights, 1));
    % end
    % [pvaf, pvafs, vars] = eeg_pvaf(EEG, goodICs, 'plot', 'off');
    % EEG.etc.pvaf = pvaf;
    % EEG.etc.pvafs = pvafs;
    % EEG.etc.vars = vars;
    % save sets
    EEG.setname = strcat(ID{i}, '_dipfit');
    EEG = pop_saveset(EEG, 'filename', outName); % save set
    EEG = eeg_checkset(EEG);
    EEG = [];
end

