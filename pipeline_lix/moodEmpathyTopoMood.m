% theta: 5.5-7.5Hz, 500-600ms
% alpha: 10.5-12Hz, 850-950ms
% beta: 18-20Hz, 500-600ms
%% prepare input parameters
% clear, clc

% indir = '/home/lix/data/Mood-Pain-Empathy/';
% outdir = fullfile(indir, 'image');
% if ~exist(outdir, 'dir'); mkdir(outdir); end
% load(fullfile(indir, 'painEmpathy_final.mat'));

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
tagBands = {'theta', 'alpha', 'beta1', 'beta2'};
chanlabels = [STUDY.changrp.channels];
freqs = STUDY.changrp.erspfreqs;
times = STUDY.changrp.ersptimes;
nSubj = numel(STUDY.subject);
nCond = numel(STUDY.design.variable(1).value);

if numel(tagBands)>1
    erspSubset = zeros(numel(tagBands), numel(chanlabels), nSubj, nCond);
    for iBand = 1:numel(tagBands)
        roi = eval(tagBands{iBand});
        f = dsearchn(freqs', roi(1:2)');
        t = dsearchn(times', roi(3:4)');
        for iChan = 1:numel(chanlabels)
            tmp = [STUDY.changrp(iChan).erspdata];
            [d1,d2,d3] = size(tmp{1});
            d4 = numel(tmp);
            tmp = reshape(cell2mat(tmp), [d1, d4, d2, d3]);
            tmp = permute(tmp, [1,3,4,2]);
            tmp = squeeze(mean(mean(tmp(f(1):f(2), t(1):t(2), :, :),1),2));
            erspSubset(iBand, iChan, :, :) = tmp;
        end
        neg = erspSubset(:,:,:,2)-erspSubset(:,:,:,1);
        neu = erspSubset(:,:,:,4)-erspSubset(:,:,:,3);
        pos = erspSubset(:,:,:,6)-erspSubset(:,:,:,5);
        dataDiff = {neg, neu, pos}; % band * chan * sub
        dataDiff = reshape(cell2mat(dataDiff), [size(dataDiff{1}), ...
                            numel(dataDiff)]);
        dataDiff = squeeze(mean(dataDiff, 3));
    end
else
    erspSubset = zeros(numel(chanlabels), nSubj, nCond);
    roi = eval(tagBands{:});
    f = dsearchn(freqs', roi(1:2)');
    t = dsearchn(times', roi(3:4)');
    for iChan = 1:numel(chanlabels)
        tmp = [STUDY.changrp(iChan).erspdata];
        [d1,d2,d3] = size(tmp{1});
        d4 = numel(tmp);
        tmp = reshape(cell2mat(tmp), [d1, d4, d2, d3]);
        tmp = permute(tmp, [1,3,4,2]);
        tmp = squeeze(mean(mean(tmp(f(1):f(2), t(1):t(2), :, :),1),2));
        erspSubset(iChan, :, :) = tmp;
    end
    neg = erspSubset(:,:,2)-erspSubset(:,:,1);
    neu = erspSubset(:,:,4)-erspSubset(:,:,3);
    pos = erspSubset(:,:,6)-erspSubset(:,:,5);
    dataDiff = {neg, neu, pos}; % chan * sub
    dataDiff = reshape(cell2mat(dataDiff), [size(dataDiff{1}), ...
                        numel(dataDiff)]);
    dataDiff = squeeze(mean(dataDiff,2));
end
%
XTICKLABEL = {'Negative', 'Neutral', 'Positive'};
YLABEL = 'Differential ERSP (dB)\nBetween Pain & nonPain';
CAXIS = [-1.5 1.5];
topoOpt = {'style', 'both', 'electrodes', 'off'};
% figure('color', 'w', ...
%        'nextplot', 'add', ...
%        'PaperUnits', 'centimeters', ...
%        'PaperPositionMode', 'manual');
if numel(tagBands) > 1
    dataPlot = permute(dataDiff, [2,1,3]);
    dataPlot = mat2cell(dataPlot, size(dataPlot,1), ...
                        ones(1, size(dataPlot,2)), ...
                        ones(1, size(dataDiff,3)));
    dataPlot = squeeze(dataPlot)';
    std_chantopo(dataPlot, ...
                 'chanlocs', STUDY.chanlocs, ...
                 'topoplotopt', topoOpt,...
                 'datatype', 'spec', ...
                 'caxis', CAXIS);
else
    dataPlot = mat2cell(dataPlot, size(dataPlot, 1), ...
                        ones(1, size(dataPlot, 2)));
    dataPlot = squeeze(dataPlot)';
    std_chantopo(dataPlot, ...
                 'chanlocs', STUDY.chanlocs, ...
                 'topoplotopt', topoOpt,...
                 'datatype', 'spec',...
                 'caxis', CAXIS);
end
hline = findobj(gcf, 'type', 'line');
set(hline, 'linewidth', 1);
% save image
outName = strcat('topoERSP_', ...
                 cellstrcat(tagBands, '-'));
print(gcf, '-djpeg', '-cmyk', '-painters', ...
      fullfile(outdir, strcat(outName, '.jpg')));
print(gcf, '-depsc', '-painters', ...
      fullfile(outdir, strcat(outName, '.eps')));
close all
