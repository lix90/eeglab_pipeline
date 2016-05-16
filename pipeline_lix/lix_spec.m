%% script for computing psd and sample entropy

clear, clc, close all;
baseDir = '~/Data/moodPain_final/';
inputDir = fullfile(baseDir, 'interp_rv100');
outputDir = fullfile(baseDir, 'CRBPow_rv100');
EpochTime = [-1 2];
poolsize = 8;
marks = {'Neg_noPain', 'Neg_Pain', ...
         'Neu_noPain', 'Neu_Pain', ...
         'Pos_noPain', 'Pos_Pain'};
%%--------------------------------------------------------
eeglabDir = fileparts(which('eeglab.m'));
addpath(genpath(eeglabDir))

% prepare datasets
if ~exist(inputDir, 'dir'); disp('inputDir does not exist'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

tmp = dir(fullfile(inputDir, '*.set'));
fileName = {tmp.name};
nFile = numel(fileName);
ID = get_prefix(fileName, 1);
ID = unique(ID);

% if matlabpool('size') < poolsize
%     matlabpool('local', poolsize)
% end

for i = 1:nFile
    % ALLEEG = []; EEG = []; CUURENTSET = 0;
    % loading
    fprintf('Loading (%i/%i %s)\n', i, nFile, fileName{i});
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    % [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    EEG = eeg_checkset(EEG);
    par.chanlocs = EEG.chanlocs;
    % epoch
    for imarks = 1:numel(marks)

        %% setting for CBRanalysis
        par.CRBpar.spectrapar.Nfft = 2^11;
        par.savepar.mat = 1;
        par.savepar.matpar.filepath = outputDir;
        par.savepar.matpar.includeavespectra = 1;
        par.CRBpar.timeintervals.ref_int = [-700 -200];
        par.CRBpar.timeintervals.test_int= [300 800];

        namePow = strcat(ID{i}, '_', marks{imarks}, '_CBRPow.mat');
        par.savepar.matpar.filename = namePow;
        filePath = fullfile(outputDir, namePow);
        if exist(filePath, 'file'); continue; end
        EEGtmp = pop_epoch(EEG, marks(imarks), EpochTime);
        % EEG = eeg_checkset(EEG);
        % [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, imarks, 'gui', 'off');
        % EEG = eeg_checkset(EEG);
        % EEGtmp = pop_rmbase(EEGtmp, []);
        % [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, imarks, 'gui', 'off');
        % try
        EEGtmp = pop_CRBanalysis(EEGtmp, 1, par);
        EEGtmp = [];
        % catch
        %     fprintf('error happen in %s of %s\n', marks{imarks}, fileName{i});
        %     continue
        % end
        % [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, imarks, 'retrieve', 1);
    end
    EEG = [];
end
