% theta: 5.5-7.5Hz, 500-600ms
% alpha: 10.5-12Hz, 850-950ms
% beta: 18-20Hz, 500-600ms
%% prepare input parameters
clear, clc

indir = '/home/lix/data/Mood-Pain-Empathy/';
outdir = fullfile(indir, 'image');
if ~exist(outdir, 'dir'); mkdir(outdir); end
load(fullfile(indir, 'erspMoodEmpathy.mat'));

%%
theta = [4, 7, 200, 600];
alpha = [8, 12, 400, 800];
beta1 = [13, 20, 300, 700];
beta2 = [21, 30, 300, 700];
% tagChans = {'C3', 'C1', 'Cz', 'C2', 'C4'};
% tagBands = {'alpha', 'beta1', 'beta2'};
% tagBands = {'alpha'};
% tagChans = {'O1', 'Oz', 'O2'};
% tagBands = {'theta', 'alpha'};
% tagChans = {'F5', 'F3', 'Fz', 'F2', 'F4'};

ersp = {STUDY.changrp.erspdata};
chanlabels = [STUDY.changrp.channels];
freqs = STUDY.changrp.erspfreqs;
times = STUDY.changrp.ersptimes;
nSubj = numel(STUDY.subject);
[x,y,z] = size(ersp{1});
nCond = numel(STUDY.design.variable(1).value);

if numel(tagBands)>1
    erspSubset = zeros(numel(tagBands), numel(tagChans), nSubj, nCond);
    for iBand = 1:numel(tagBands)
        roi = eval(tagBands{iBand});
        f = dsearchn(freqs', roi(1:2)');
        t = dsearchn(times', roi(3:4)');
        for iChan = 1:numel(tagChans)
            indChan = find(ismember(chanlabels, tagChans(iChan)));
            tmp = [STUDY.changrp(indChan).erspdata];
            tmp = reshape(cell2mat(tmp), [size(tmp{1}),numel(tmp)]);
            tmp = squeeze(mean(mean(tmp(f(1):f(2), t(1):t(2), :, :),1),2));
            erspSubset(iBand, iChan, :, :) = tmp;
        end
    end
    neg = erspSubset(:,:,:,1)-erspSubset(:,:,:,2);
    neu = erspSubset(:,:,:,3)-erspSubset(:,:,:,4);
    pos = erspSubset(:,:,:,5)-erspSubset(:,:,:,6);
    dataDiff = {neg, neu, pos}; % band * chan * sub
    dataDiff = reshape(cell2mat(dataDiff), [size(dataDiff{1}), numel(dataDiff)]);
    dataMN = squeeze(mean(dataDiff, 3)); % band*chan*cond
    dataSE = squeeze(std(dataDiff, 1, 3)/sqrt(size(dataDiff, 3)));
else
    erspSubset = zeros(numel(tagChans), nSubj, nCond);
    roi = eval(tagBands{:});
    f = dsearchn(freqs', roi(1:2)');
    t = dsearchn(times', roi(3:4)');
    for iChan = 1:numel(tagChans)
        indChan = find(ismember(chanlabels, tagChans(iChan)));
        tmp = [STUDY.changrp(indChan).erspdata];
        tmp = reshape(cell2mat(tmp), [size(tmp{1}),numel(tmp)]);
        tmp = squeeze(mean(mean(tmp(f(1):f(2), t(1):t(2), :, :),1),2));
        erspSubset(iChan, :, :) = tmp;
    end
    neg = erspSubset(:,:,1)-erspSubset(:,:,2);
    neu = erspSubset(:,:,3)-erspSubset(:,:,4);
    pos = erspSubset(:,:,5)-erspSubset(:,:,6);
    dataDiff = {neg, neu, pos}; % band * chan * sub
    dataDiff = reshape(cell2mat(dataDiff), [size(dataDiff{1}), numel(dataDiff)]);
    dataMN = squeeze(mean(dataDiff, 2)); % band*chan*cond
    dataSE = squeeze(std(dataDiff, 1, 2)/sqrt(size(dataDiff, 2)));
end
%
XTICKLABEL = {'Negative', 'Neutral', 'Positive'};
YLABEL = 'Differential ERSP (dB)\nBetween Pain & nonPain';

figure('color', 'w', ...
       'nextplot', 'add', ...
       'PaperUnits', 'centimeters', ...
       'PaperPositionMode', 'manual');
if numel(tagBands)>1
    for i = 1:numel(tagBands)
        subplot(numel(tagBands), 1, i);
        TITLE = {sprintf('Errorbar (stderr) of %s %s', ...
                         tagBands{i})};
        [hbar, herr] = barwitherr(squeeze(dataSE(i,:,:))', ...
                                  squeeze(dataMN(i,:,:))');
        set(hbar, 'EdgeColor', 'w');
        set(herr, 'LineWidth', 1, 'Color', 'k');
        set(gca, 'XTickLabel', XTICKLABEL);
        title(TITLE);
        LEGEND = tagChans;
        ylabel(YLABEL);
        legend(gca, 'string', LEGEND, 'Location', 'SouthEastOutside');
    end
else
    TITLE = {sprintf('Errorbar (stderr) of %s %s', ...
                     tagBands{:})};
    [hbar, herr] = barwitherr(squeeze(dataSE)', ...
                              squeeze(dataMN)');
    set(hbar, 'EdgeColor', 'w');
    set(herr, 'LineWidth', 1, 'Color', 'k');
    set(gca, 'XTickLabel', XTICKLABEL);
    ylabel(YLABEL)
    title(TITLE);
    LEGEND = tagChans;
    legend(gca, 'string', LEGEND, 'Location', 'SouthEastOutside');
end
% save image
outName = strcat('errBarSpec_', ...
                 cellstrcat(tagChans, '-'));
print(gcf, '-djpeg', '-cmyk', '-painters', ...
      fullfile(outdir, strcat(outName, '.jpg')));
print(gcf, '-depsc', '-painters', ...
      fullfile(outdir, strcat(outName, '.eps')));
close all
