%% script for computing psd and sample entropy

clear, clc, close all;
baseDir = '~/Data/dingyi/';
inputDir = fullfile(baseDir, 'interp');
pwelchDir = fullfile(baseDir, 'pwelch');
samEnDir = fullfile(baseDir, 'samEn');
restLength = 30;
cut = 2;
tags = {'rest', 'task1', 'task2', 'task3'};
marks = {'2', '4', '5', '6'};

%%--------------------------------------------------------
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

ALLEEG = []; EEG = [];

for i = 1:nFile

    namePwelch = strcat(ID{i}, '_pwelch.mat');
    nameSamEn = strcat(ID{i}, '_samEn.mat');
    fprintf('Loading (%i/%i %s)\n', i, nFile, fileName{i});
    % loading
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    EEG = eeg_checkset(EEG);
    % epoch
    latency = round([EEG.event.latency]/EEG.srate);
    if numel(latency)==6
        latency = [0 latency];
    end
    restDuration = latency(2)-latency(1)-2;
    if restDuration<restLength
        continue
    end
    ilatency = [2 4 5 6 7];
    for itag = 1:numel(tags)
        fprintf('spectral analysis of %s\n', tags{itag});
        outNamePwelch = fullfile(pwelchDir, strcat(tags{itag}, '_', ...
                                                   namePwelch));
        outNameSamEn = fullfile(samEnDir, strcat(tags{itag}, '_', ...
                                                 nameSamEn));
        if exist(outName, 'file'); continue; end
        if itag == 1 % rest
            EEG = pop_epoch(EEG, marks(itag), ...
                            [-(restDuration+cut), -cut]);
            EEG = eeg_checkset(EEG);
        else
            EEG = pop_epoch(EEG, marks(itag), ...
                            [0, latency(ilatency(itag+1))-latency(ilatency(itag))-cut]);
        end
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, itag, 'gui', 'off');
        EEG = eeg_checkset(EEG);
        EEG = pop_rmbase(EEG, []);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, itag, 'gui', ...
                                             'off');
        try
            % [out.spec, out.freq, ~, ~, ~] = spectopo(EEG.data, 0, EEG.srate, ...
            %                                          'plot', 'off');
            out = lix_pwelch(EEG);
            fprintf('computing power spectral density\n');
            save(outNamePwelch, 'out');
            out = lix_samEn(EEG);
            fprintf('computing sample entropy\n');
            save(outNameSamEn, 'out');
        catch
            fprintf('error happen in %s of %s\n', tags{itag}, fileName{i});
            continue
        end
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, itag, 'retrieve', 1);
    end
    EEG = []; ALLEEG = []; CURRENTSET = 0;
end
