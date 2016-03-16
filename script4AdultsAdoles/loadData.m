clear, clc
indir = '~/data/adolesvsadult/conditiondata/';
% load data
load(fullfile(indir, 'info.mat'));
load(fullfile(indir, 'chanlocs.mat'));
load(fullfile(indir, 'ahighersp.mat'));
load(fullfile(indir, 'amediumersp.mat'));
load(fullfile(indir, 'aneutralersp.mat'));
load(fullfile(indir, 'chighersp.mat'));
load(fullfile(indir, 'cmediumersp.mat'));
load(fullfile(indir, 'cneutralersp.mat'));
data = { ahighersp, chighersp(:,:,:,21:end);
         amediumersp, cmediumersp(:,:,:,21:end);
         aneutralersp, cneutralersp(:,:,:,21:end) };
