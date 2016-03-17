clear, clc
indir = '~/data/adolesvsadult/conditiondata/ersp/';
cd(indir)
% load data
load(fullfile(indir, 'info.mat'));
load(fullfile(indir, 'chanlocs.mat'));
g1c1 = load(fullfile(indir, 'ersp_g1_c1.mat'));
g1c2 = load(fullfile(indir, 'ersp_g1_c2.mat'));
g1c3 = load(fullfile(indir, 'ersp_g1_c3.mat'));
g2c1 = load(fullfile(indir, 'ersp_g2_c1.mat'));
g2c2 = load(fullfile(indir, 'ersp_g2_c2.mat'));
g2c3 = load(fullfile(indir, 'ersp_g2_c3.mat'));

% data = {g1c1.outfile, g2c1.outfile;
%         g1c2.outfile, g2c2.outfile;
%         g1c3.outfile, g2c3.outfile};

group1 = {g1c1.outfile, g1c2.outfile, g1c3.outfile};
group2 = {g2c1.outfile, g2c2.outfile, g2c3.outfile};

tRange = [-200 1000];
fRange = [3 30];
iT = dsearchn(times', tRange');
iF = dsearchn(freqs', fRange');
downTime = downsample([iT(1):iT(2)], 2);
downFreq = iF(1):iF(2);
group1 = cellfun(@(x) {permute(x, [4,3,2,1])}, group1);
group2 = cellfun(@(x) {permute(x, [4,3,2,1])}, group2);
group1Subset = cellfun(@(x) {x(:,:,downTime,downFreq)}, group1);
group2Subset = cellfun(@(x) {x(:,:,downTime,downFreq)}, group2);
save group1 group1Subset
save group2 group2Subset
