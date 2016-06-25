indir = '';
load(fullfile(indir, 'data_ersp.mat'));
load(fullfile(indir, 'chanlocs.mat'));
tRange = [-200 1000];
fRange = [3 30];
iT = dsearchn(times', tRange');
iF = dsearchn(freqs', fRange');
downTime = downsample([iT(1):iT(2)], 2);
downFreq = iF(1):iF(2);
dataTFCE = cellfun(@(x) {x(:,:,downTime,downFreq)}, data);
% tfce
out = ept_TFCE_ANOVA(dataTFCE, chanlocs);
