% theta: 5.5-7.5Hz, 500-600ms
% alpha: 10.5-12Hz, 850-950ms
% beta: 18-20Hz, 500-600ms
%% prepare input parameters
clear, clc

inputDir = '/home/lix/data/Mood-Pain-Empathy/';
outputDir = fullfile(inputDir, 'csv');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
load(fullfile(inputDir, 'erspMoodEmpathy.mat'));
outName = sprintf('painERSP.csv');
%%
theta = [4, 7, 200, 600];
alpha = [8, 12, 400, 800];
beta1 = [13, 20, 300, 700];
beta2 = [21, 30, 300, 700];
tagChans = {'C3', 'C1', 'Cz', 'C2', 'C4'};
% tagBands = {'alpha', 'beta1', 'beta2'};
% tagBands = {'alpha'};
% tagChans = {'O1', 'Oz', 'O2'};
% tagBands = {'theta', 'alpha'};
% tagChans = {'F5', 'F3', 'Fz', 'F2', 'F4'};
% tagChans = {'FC3', 'FCz', 'FC4'};
tagBands = {'theta', 'alpha', 'beta1', 'beta2'};

chanlabels = [STUDY.changrp.channels];
freqs = STUDY.changrp.erspfreqs;
times = STUDY.changrp.ersptimes;
nSubj = numel(STUDY.subject);
nCond = numel(STUDY.design.variable(1).value);
nBand = numel(tagBands);
nChan = numel(tagChans);

erspSubset = zeros(nBand, nChan, nSubj, nCond);

if nBand > 1
    outFile = fullfile(outputDir, outName);
    if exist(outFile, 'file'); continue; end
    for iBand = 1:nBand
        roi = eval(tagBands{iBand});
        f = dsearchn(freqs', roi(1:2)');
        t = dsearchn(times', roi(3:4)');
        for iChan = 1:nChan
            indChan = find(ismember(chanlabels, tagChans(iChan)));
            tmp = [STUDY.changrp(indChan).erspdata];
            [d1,d2,d3] = size(tmp{1});
            d4 = numel(tmp);
            tmp = reshape(cell2mat(tmp), [d1, d4, d2, d3]);
            tmp = permute(tmp, [1,3,4,2]);
            tmp = squeeze(mean(mean(tmp(f(1):f(2), t(1):t(2), :, :),1),2));
            erspSubset(iBand, iChan, :, :) = tmp;
        end
    end
    % band * chan * cond * subj
    output.band = repmat(tagBands', [nChan*nCond*nSubj, 1]);
    output.chan = repmat(tagChans, [nBand, nCond*nSubj]); 
    output.chan = output.chan(:);
    output.pain = repmat({'Pain', 'nonPain'}, [nBand*nChan, 3*nSubj]); 
    output.pain = output.pain(:);
    output.mood = repmat({'Negative', 'Neutral', 'Positive'}, ...
                         [nBand*nChan*2, nSubj]); 
    output.mood = output.mood(:);
    output.subj = repmat(STUDY.subject, [nBand*nChan*nCond, 1]); 
    output.subj = output.subj(:);
    [d1,d2,d3,d4] = size(erspSubset);
    output.ersp = reshape(erspSubset, [d1,d2,d3*d4]);
    output.ersp = reshape(erspSubset, [d1,])
    struct2csv(output, outFile);
elseif nBand == 1
    outFile = fullfile(outputDir, strcat('PostAlpha_', outName));
    if exist(outFile, 'file'); continue; end
    erspSubset = squeeze(erspSubset);
    roi = eval(tagBands{:});
    f = dsearchn(freqs', roi(1:2)');
    t = dsearchn(times', roi(3:4)');
    for iChan = 1:nChan
        indChan = find(ismember(chanlabels, tagChans(iChan)));
        tmp = [STUDY.changrp(indChan).erspdata];
        [d1,d2,d3] = size(tmp{1});
        d4 = numel(tmp);
        tmp = reshape(cell2mat(tmp), [d1, d4, d2, d3]);
        tmp = permute(tmp, [1,3,4,2]);
        tmp = squeeze(mean(mean(tmp(f(1):f(2), t(1):t(2), :, :),1),2));
        erspSubset(iChan, :, :) = tmp;
    end
    % chan * cond * subj
    output.chan = repmat(tagChans, [1, nCond*nSubj]); 
    output.chan = output.chan(:);
    output.pain = repmat({'Pain', 'nonPain'}, [nChan, 3*nSubj]); 
    output.pain = output.pain(:);
    output.mood = repmat({'Negative', 'Neutral', 'Positive'}, ...
                         [nChan*2, nSubj]); 
    output.mood = output.mood(:);
    output.subj = repmat(STUDY.subject, [nChan*nCond, 1]); 
    output.subj = output.subj(:);
    output.ersp = erspSubset(:);
    struct2csv(output, outFile);
end
