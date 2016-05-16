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
theta = [200, 600, 4, 7];
alpha = [400, 800, 8, 12];
beta1 = [300, 700, 13, 20];
beta2 = [300, 700, 21, 30];
% tagChans = {'C3', 'C1', 'Cz', 'C2', 'C4'};
tagBands = {'theta', 'alpha', 'beta1', 'beta2'};

chanlabels = [STUDY.changrp.channels];
freqs = STUDY.changrp.erspfreqs;
times = STUDY.changrp.ersptimes;
nSubj = numel(STUDY.subject);
nCond = numel(STUDY.design.variable(1).value);

erspMean = zeros(numel(freqs), numel(times), numel(chanlabels));
for iChan = 1:numel(chanlabels)
    tmp = [STUDY.changrp(iChan).erspdata];
    [d1,d2,d3] = size(tmp{1});
    d4 = numel(tmp);
    tmp = reshape(cell2mat(tmp), [d1, d4, d2, d3]);
    tmp = permute(tmp, [1,3,4,2]);
    tmp = squeeze(mean(mean(tmp, 3), 4));
    erspMean(:, :, iChan) = tmp;
end
% erspMean = permute(erspMean, [2,1,3]); % to time*freq*chan
% erspMean = squeeze(mean(erspMean, 3));

YLABEL = 'Differential ERSP (dB)\nBetween Pain & nonPain';
% figure('color', 'w', ...
%        'nextplot', 'add', ...
%        'PaperUnits', 'centimeters', ...
%        'PaperPositionMode', 'manual');
for iBand = 1:numel(tagBands)
    figure; tftopo(erspMean, times, freqs, ...
                   'timefreqs', eval(tagBands{iBand}), ...
                   'chanlocs', STUDY.chanlocs, ...
                   'limits', [-200 1200 3 30 -3 3],...
                   'logfreq', 'native');
    % imagesclogy(times, freqs, erspMean);
    % save image
    outName = sprintf('GrandAvg_%s', tagBands{iBand});
    print(gcf, '-djpeg', '-cmyk', '-painters', ...
          fullfile(outdir, strcat(outName, '.jpg')));
    print(gcf, '-depsc', '-painters', ...
          fullfile(outdir, strcat(outName, '.eps')));
end
close all
