clear, clc
% indir1 = '~/data/Adult-Adole-Emotion/';
indir = '/home/lix/Data/adultvsadole/conditiondata/';

% load data
% load(fullfile(indir1, 'info.mat'));
% load(fullfile(indir1, 'chanlocs.mat'));
load(fullfile(indir, 'ADUHersp.mat'));
load(fullfile(indir, 'ADUMersp.mat'));
load(fullfile(indir, 'ADUNersp.mat'));
load(fullfile(indir, 'ADOHersp.mat'));
load(fullfile(indir, 'ADOMersp.mat'));
load(fullfile(indir, 'ADONersp.mat'));
load(fullfile(indir, 'tim.mat'));
load(fullfile(indir, 'fre.mat'));
load(fullfile(indir, 'chanlabels.mat'));
data = {ADUHersp, ADOHersp;
        ADUMersp, ADOMersp;
        ADUNersp, ADONersp};

% group1 = {g1c1.outfile, g1c2.outfile, g1c3.outfile};
% group2 = {g2c1.outfile, g2c2.outfile, g2c3.outfile};

% tRange = [-200 1000];
% fRange = [3 30];
% iT = dsearchn(times', tRange');
% iF = dsearchn(freqs', fRange');
% downTime = downsample([iT(1):iT(2)], 2);
% downFreq = iF(1):iF(2);
% group1 = cellfun(@(x) {permute(x, [4,3,2,1])}, group1);
% group2 = cellfun(@(x) {permute(x, [4,3,2,1])}, group2);
% group1Subset = cellfun(@(x) {x(:,:,downTime,downFreq)}, group1);
% group2Subset = cellfun(@(x) {x(:,:,downTime,downFreq)}, group2);
% save group1 group1Subset
% save group2 group2Subset
