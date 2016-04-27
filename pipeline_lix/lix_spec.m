%% script for computing psd and sample entropy

clear, clc, close all;
baseDir = '~/Data/dingyi/';
inputDir = fullfile(baseDir, 'interp');
pwelchDir = fullfile(baseDir, 'CBRPow');
EpochTime = [-1 2];
poolsize = 8;
marks = {'Neg_noPain', 'Neg_Pain', ...
         'Neu_noPain', 'Neu_Pain', ...
         'Pos_noPain', 'Pos_Pain'};

%% setting for CBRanalysis
par.CBRpar.timeintervals.ref_int = [-1000 0];
par.CRBpar.timeintervals.test_int= [0 2000];
par.CRBpar.spectrapar.Nfft = 2^11;
par.savepar.mat=1;
par.savepar.matpar.filepath = outputDir;
par.savepar.matpar.includeavespectra = 1;

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

if matlabpool('size') < poolsize
    matlabpool('local', poolsize)
end

ALLEEG = []; EEG = [];

parfor i = 1:nFile
    
    % loading
    fprintf('Loading (%i/%i %s)\n', i, nFile, fileName{i});
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    EEG = eeg_checkset(EEG);
    par.chanlocs = EEG.chanlocs;

    % epoch
    for imarks = 1:numel(marks)
    
        namePow = strcat(ID{i}, '_', marks{imarks}, '_CBRPow.mat')
        par.savepar.matpar.filename = namePow;
        filePath = fullfile(outputDir, namePow);
        if exist(filePath, 'file'); continue; end
        
        EEG = pop_epoch(EEG, marks(imarks), EpochTime);
        EEG = eeg_checkset(EEG);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, imarks, 'gui', 'off');
        EEG = eeg_checkset(EEG);
        EEG = pop_rmbase(EEG, []);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, imarks, 'gui', ...
                                             'off');
        try
            EEG = pop_CRBanalysis(EEG, 1, par);
        catch
            fprintf('error happen in %s of %s\n', tags{itag}, fileName{i});
            continue
        end
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, itag, 'retrieve', 1);
    end
    EEG = []; ALLEEG = []; CURRENTSET = 0;
end
