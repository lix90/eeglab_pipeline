% plot parameters
t = [200 400];
f = [10 14];
colLimits = [];

% stats parameters
method = 'param';
alpha = 0.05;

%% compute
CHANS = {STUDY.changrp.channels};
Nchan = numel(CHANS);
p = zeros(Nchan, 1);
table = cell(Nchan, 1);
for iChan = 1:Nchan
    % compute ersp
    chanNow = CHANS(iChan);
    [STUDY, erspData, erspTimes, erspFreqs] = ...
        std_erspplot(STUDY, ALLEEG, ...
                     'plotsubjects', 'off', ...
                     'channels', chanNow, ...
                     'plotmode', 'none', ...
                     'subbaseline', 'on');
    % erspData = freq * time * chan * subject
    iT = dsearchn(erspTimes', t');
    iF = dsearchn(erspFreqs', f');
    ersp = cellfun(@(x) {squeeze(x)}, erspData);
    erspAvg = cellfun(@(x) {squeeze(mean(mean(x(iF(1):iF(2), iT(1):iT(2), :), 1), 2))}, ersp);
    % erspAvg = across subject data
    erspAvgDiff = {erspAvg{1}-erspAvg{2},...
                   erspAvg{3}-erspAvg{4},...
                   erspAvg{5}-erspAvg{6}};
    X = [erspAvgDiff{1}, erspAvgDiff{2}, erspAvgDiff{3}];
    pvals = anova_rm(X, 'off');
    p(iChan) = pvals(1);
end

%% plot
figure('Name', 'significant channels');
in = p < alpha;
mergelocs = eeg_mergelocs(ALLEEG.chanlocs);
if any(in)
    markChans = find(in);
    emarker2 = {markChans, '.', 'r', 20, 20};
    topoplot(p, mergelocs, ...
             'style', 'map', ...
             'electrodes', 'ptslabels', ...
             'emarker2', emarker2, ...
             'shading', 'flat', ...
             'whitebk', 'off');
    caxis([0 0.05]);
    colorbar;
    axis square; colormap winter;
else
    topoplot(p, mergelocs, ...
             'style', 'map', ...
             'electrodes', 'ptslabels', ...
             'shading', 'flat', ...
             'whitebk', 'off');
    caxis([0 0.05]);
    axis square;
    colorbar; colormap summer;
end
