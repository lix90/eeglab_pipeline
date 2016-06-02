% theta: 5.5-7.5Hz, 500-600ms
% alpha: 10.5-12Hz, 850-950ms
% beta: 18-20Hz, 500-600ms
%% prepare input parameters
clear, clc

inputDir = '/home/lix/data/Mood-Pain-Empathy/';
outputDir = fullfile(inputDir, 'csv');
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
load(fullfile(inputDir, 'painEmpathy_final.mat'));
%%
time = [200,300];
% theta = [4, 7, 200, 600];
% alpha = [8, 12, 400, 800];
% beta1 = [13, 20, 300, 700];
% beta2 = [21, 30, 300, 700];
tagChans = {'C3', 'Cz', 'C4'};
tagBands = {'alpha', 'beta1', 'beta2'};
% tagBands = {'alpha'};
% tagChans = {'O1', 'Oz', 'O2'};
% tagBands = {'theta', 'alpha'};
% tagChans = {'F5', 'F3', 'Fz', 'F2', 'F4'};
% tagChans = {'FC3', 'FCz', 'FC4'};
% tagBands = {'theta', 'alpha', 'beta1', 'beta2'};

outName = sprintf('painERSP_f%i-%i_t%i-t%i.csv');
chanlabels = [STUDY.changrp.channels];
freqs = STUDY.changrp.erspfreqs;
times = STUDY.changrp.ersptimes;
nSubj = numel(STUDY.subject);
tagConds = STUDY.design.variable(1).value;
nCond = numel(STUDY.design.variable(1).value);
nBand = numel(tagBands);
nChan = numel(tagChans);

erspSubset = zeros(nBand, nChan, nSubj, nCond);

output.subj = STUDY.subject';
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
        for iCond = 1:6
            fieldName = sprintf('%s_%s_%s', tagBands{iBand}, ...
                                tagChans{iChan}, tagConds{iCond})
            output.(fieldName) = tmp(:, iCond);
        end
    end
end
struct2csv(output, outFile);

