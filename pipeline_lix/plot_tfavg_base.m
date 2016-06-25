%% script for plotting ersp & itc grand average image
% plot grand avg tf image
colLimits = [-2 2];
yLimits = [3 30];
yTicks =  [4 6 8 10 12 14 16 20 25 30];
xLimits = [-200 1400];
xTicks = [-200, 0:200:1400];
chanLabels = {'C3'};
% statistics
alpha = 0.01;

%% compute
% ersp
if isempty(chanLabels)
    chanNow = {STUDY.changrp.channels};
    figureTitle = 'grand average tf image';
elseif iscellstr(chanLabels)
    chanNow = chanLabels;
    num = numel(chanLabels);
    if num == 1
        strLabels = char(chanLabels);
    elseif num > 1
        strLabels = [];
        for i = 1:num
            if i == num
                strLabels = [strLabels, chanLabels{i}];
            else
                strLabels = [strLabels, chanLabels{i}, '-'];
            end
        end
    end
    figureTitle = sprintf('grand average tf image of %s', strLabels);
end
[STUDY, erspData, erspTimes, erspFreqs] = ...
    std_erspplot(STUDY, ALLEEG, ...
                 'plotsubjects', 'off', ...
                 'channels', chanNow,...
                 'plotmode', 'none',...
                 'subbaseline', 'on');
ersp = cellfun(@(x) {squeeze(mean(x, 3))}, erspData);
erspAvg = cellfun(@(x) {squeeze(mean(mean(x, 3),4))}, erspData);
erspAvg = (erspAvg{1}+erspAvg{2}+erspAvg{3}+erspAvg{4}+erspAvg{5}+ ...
           erspAvg{6})/6;
ersp = (ersp{1}+ersp{2}+ersp{3}+ersp{4}+ersp{5}+ ...
        ersp{6})/6;

%% statistics
baseStatData = {ersp, zeros(size(ersp))};
[stats, df, pvals] = statcond(baseStatData, ...
                              'paired', 'on', ...
                              'method', 'param');
baseThresh = pvals < alpha;
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
imagesclogy(erspTimes, erspFreqs, erspAvg);
set(gca, 'ydir', 'normal')
colormap jet;
axis square
set(gca,'clim', colLimits, 'xlim', [-200 1400], ...
        'ylim', yLimits, 'xtick', xTicks, 'ytick', yTicks);
title(figureTitle, 'fontsize', 12);
xlabel('Time (ms)', 'fontsize', 12);
ylabel('Frequency (Hz)', 'fontsize', 12);
% ersp mask
hs2 = subplot(122);
imagesclogy(erspTimes, erspFreqs, baseThresh);
set(gca, 'ydir', 'normal')
axis square
set(gca,'clim', [0 1], 'xlim', [-200 1400], ...
        'ylim', yLimits, 'xtick', xTicks, 'ytick', yTicks);
title(figureTitle, 'fontsize', 12);
xlabel('Time (ms)', 'fontsize', 12);
ylabel('Frequency (Hz)', 'fontsize', 12);
