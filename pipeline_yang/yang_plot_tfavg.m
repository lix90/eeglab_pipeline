%% script for plotting ersp & itc grand average image
% plot grand avg tf image
colLimits = [-2 2];
yLimits = [3 30];
yTicks =  [4 6 8 10 12 14 16 20 25 30];
xLimits = [-200 1400];
xTicks = [-200, 0:200:1400];
chanLabels = {'O1', 'Oz', 'O2'};

% compute
% ersp
if isempty(chanLabels)
    chanNow = {STUDY.changrp.channels};
    figureTitle = 'grand average tf image';
elseif iscellstr(chanLabels)
    chanNow = chanLabels;
    strLabels = cellstrcat(chanLabels, '-');
    figureTitle = sprintf('grand average tf image of %s', strLabels);
end
[STUDY, erspData, erspTimes, erspFreqs] = ...
    std_erspplot(STUDY, ALLEEG, ...
                 'plotsubjects', 'off', ...
                 'channels', chanNow,...
                 'plotmode', 'none',...
                 'subbaseline', 'on');
erspAvg = cellfun(@(x) {squeeze(mean(mean(x, 3),4))}, erspData);
erspAvg = (erspAvg{1}+erspAvg{2}+erspAvg{3}+erspAvg{4}+erspAvg{5}+ ...
           erspAvg{6})/6;
% itc
% [STUDY, itcData, itcTimes, itcFreqs] = ...
%     std_itcplot(STUDY, ALLEEG, ...
%                  'plotsubjects', 'off', ...
%                  'channels', chanNow,...
%                  'plotmode', 'none',...
%                  'subbaseline', 'on');
% itcAvg = cellfun(@(x) {squeeze(mean(mean(x, 3),4))}, itcData);
% itcAvg = (itcAvg{1}+itcAvg{2}+itcAvg{3}+itcAvg{4}+itcAvg{5}+ ...
%            itcAvg{6})/6;

% plotting
% ersp
figure('Name', figureTitle, ...
       'color', 'w');
hs1 = subplot(121);
contourf(erspTimes, erspFreqs, erspAvg, 40, ...
                  'linestyle', 'none');
colormap jet;
axis square
set(gca,'clim', colLimits, 'xlim', [-200 1400], ...
        'ylim', yLimits, 'xtick', xTicks, 'ytick', yTicks);
title(figureTitle, 'fontsize', 12);
xlabel('Time (ms)', 'fontsize', 12);
ylabel('Frequency (Hz)', 'fontsize', 12);
freezeColors;
cbfreeze(colorbar);
% itc
% hs2 = subplot(122);
% contourf(itcTimes, itcFreqs, itcAvg, 40, ...
%                  'linestyle', 'none');
% colormap hot;
% axis square
% set(gca,'clim', [0 0.7], 'xlim', [-200 1400], ...
%         'ylim', yLimits, 'xtick', xTicks, 'ytick', yTicks);
% title(figureTitle, 'fontsize', 12);
% xlabel('Time (ms)', 'fontsize', 12);
% ylabel('Frequency (Hz)', 'fontsize', 12);
% freezeColors;
% cbfreeze(colorbar);
