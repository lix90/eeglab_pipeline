% theta: 5.5-7.5Hz, 500-600ms
% alpha: 10.5-12Hz, 850-950ms
% beta: 18-20Hz, 500-600ms
%% prepare input parameters
indir = '/home/lix/data/Mood-Pain-Empathy/';
outdir = fullfile(indir, 'image');
load(fullfile(indir, 'erspMoodEmpathy.mat'));

%%
alpha = [8, 12, 400, 800];
beta1 = [13, 20, 300, 700];
beta2 = [21, 30, 300, 700];
tagChans = {'C3', 'C1', 'Cz', 'C2', 'C4'};
tagBands = {'alpha', 'beta1', 'beta2'};
% tagBands = {'alpha'};
% tagChans = {'O1', 'Oz', 'O2'};
ersp = {STUDY.changrp.erspdata};
chanlabels = STUDY.changrp.channels;
[x,y,z] = size(ersp{1});
nCond = numel(STUDY.design.variable(1).value);
erspSubset = cell(6,1);
for iChan = 1:numel(tagChans)
    indChan = ismember(chanlabels, tagChans(iChan));
    for iCond = 1:nCond
        tmp = ersp{indChan};
        tmpErsp(:,:,iChan,:) = tmp{iCond};
    end
end
neg = erspSubset{1}-erspSubset{2};
neu = erspSubset{3}-erspSubset{4};
pos = erspSubset{5}-erspSubset{6};
dataDiff = {neg, neu, pos};

%%
XTICKLABEL = {'Negative', 'Neutral', 'Positive'};
YLABEL = 'Differential ERSP (dB)\nBetween Pain & nonPain';
if ~exist(outdir, 'dir'); mkdir(outdir); end
WIDTH = 10;
HEIGHT = 30;
figure('color', 'w', ...
       'nextplot', 'add', ...
       'PaperUnits', 'centimeters', ...
       'PaperPositionMode', 'manual', ...
       'papersize', [WIDTH, HEIGHT], ...
       'PaperPosition', [0 0 WIDTH HEIGHT]);
for i = 1:numel(tagBands)
    subplot(numel(tagBands), 1, i);
    roi = eval(tagBands{i});
    TITLE = {sprintf('Errorbar (stderr) of %s %s', ...
                     tagBands{i})};
    f = dsearchn(freqs', roi(1:2)');
    t = dsearchn(times', roi(3:4)');
    dataSubset = ...
        cellfun(@(x) {squeeze(mean(mean(x(f(1):f(2), t(1):t(2), :, :), 1), ...
                                   2))}, data); % chan * subject
    dataMN = cellfun(@(x) mean(x, 2), dataSubset, 'UniformOutput', false);
    dataSE = cellfun(@(x) std(x, 1, 2)/sqrt(size(x, 2)), dataSubset, ...
                     'UniformOutput', false);
    if iscell(dataMN) || iscell(dataSE)
        dataMN = cell2mat(dataMN);
        dataSE = cell2mat(dataSE);
    end
    %% plot
    [hbar, herr] = barwitherr(dataSE', dataMN');
    % set(hbar, 'EdgeColor', 'w');
    set(herr, 'LineWidth', 1, 'Color', 'k');
    set(gca, 'XTickLabel', XTICKLABEL);
    title(TITLE);
    YLIM = ylim;
    switch band{i}
      case 'theta'
        ylim([YLIM(1), YLIM(2)+0.5]);
      case 'alpha'
        ylim([YLIM(1)-0.5, YLIM(2)]);
      case 'beta'
        ylim([YLIM(1)-0.5, YLIM(2)]);
    end
    if i==3
        legend(gca, 'string', LEGEND, 'Location', 'SouthEast');
    end

end
% save image
outName = strcat('errBarSpec_', ...
                 num2str(roi(1)), '-', num2str(roi(2)), '_', ...
                 num2str(roi(3)), '-', num2str(roi(4)), '_', ...
                 cellstrcat(chan, '-'));
print(gcf, '-djpeg', '-cmyk', '-painters', ...
      fullfile(outdir, strcat(outName, '.jpg')));
print(gcf, '-depsc', '-painters', ...
      fullfile(outdir, strcat(outName, '.eps')));
% close all
