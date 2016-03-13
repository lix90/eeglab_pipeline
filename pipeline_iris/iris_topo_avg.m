% plot grand avg tf image
colLimits = [-2 2];
t = [0 200];
f = [5 7];
clear erspData
%compute
mergelocs = eeg_mergelocs(ALLEEG.chanlocs);
chanNow = {STUDY.changrp.channels};
[STUDY, erspData, erspTimes, erspFreqs] = ...
    std_erspplot(STUDY, ALLEEG, ...
                 'plotsubjects', 'off', ...
                 'channels', chanNow,...
                 'plotmode', 'none',...
                 'subbaseline', 'on');
iT = dsearchn(erspTimes', t');
iF = dsearchn(erspFreqs', f');
topoAvg = cellfun(@(x) {squeeze(mean(mean(mean(x(iF(1):iF(2), iT(1):iT(:), :, ...
                                       :), 1), 2), 4))}, erspData);
topoAvg = (topoAvg{1}+topoAvg{2}+topoAvg{3}+topoAvg{4}+topoAvg{5}+ ...
           topoAvg{6})/6;
%plot
figure;
topoplot(topoAvg, mergelocs, ...
         'style', 'map', ...
         'electrodes', 'ptslabels', ...
         'shading', 'flat', ...
         'whitebk', 'on');
set(gcf, 'Name', 'grand average topographic image', 'color', 'w');
set(gca, 'clim', colLimits);
tStr = sprintf('from%s to %sms', int2str(t(1)), int2str(t(2)));
fStr = sprintf('from%s to %sHz', int2str(f(1)), int2str(f(2)));
titleStr = sprintf('grand average topo image\n%s\n%s', tStr, fStr);
title(titleStr, 'fontsize', 12);