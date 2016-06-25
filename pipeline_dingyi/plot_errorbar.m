inDir = '~/data/dingyi/output_noRemoveWindows_1hz/';
outDir = '~/data/dingyi/image_noRemoveWindows_1hz/';
if ~exist(outDir, 'dir'); mkdir(outDir); end

load(fullfile(inDir, 'Pow.mat'));
load(fullfile(inDir, 'samEn.mat'));
load(fullfile(inDir, 'chanlocs.mat'));

chans = {chanlocs.labels};
for iChan = 1:numel(chans)

    chan = chans(iChan);
    chanStr = cellstrcat(chan, '-');
    tagBands = Pow.tagBands(1:5);
    tagStates = Pow.tagStates;
    indChan = ismember({chanlocs.labels}, chan);

    %% relative power

    relPlot = squeeze(mean(Pow.Rel(:, 1:5, indChan, :), 3));
    dataMN = squeeze(mean(relPlot, 3));
    dataSE = std(relPlot,1,3)/sqrt(size(relPlot,3));

    fn = fullfile(outDir, sprintf('lineErrorPowRelative_%s', chanStr));
    h = errorbar(dataMN, dataSE);
    % [hbar, herr] = barwitherr(dataSE', dataMN');
    set(h, 'linewidth', 2);
    set(gca, 'xticklabel', tagStates, 'xtick', [1:4]);
    set(gcf, 'color', 'w');
    YLIM = ylim;
    ylim([0 YLIM(2)]);
    legend(h, 'string', tagBands, 'location', 'SouthEastOutside');
    title('Errorbar of relative power of different states');
    ylabel('Relative power');
    print(gcf, '-djpeg', '-cmyk', '-painters', ...
          strcat(fn, '.jpg'));
    print(gcf, '-depsc', '-painters', ...
          strcat(fn, '.eps'));

    %% sample entropy
    SEPlot = squeeze(mean(sampleEn.data(:, indChan, :), 2));
    dataMN = squeeze(mean(SEPlot, 2));
    dataSE = std(SEPlot,1,2)/sqrt(size(SEPlot,2));

    fn = fullfile(outDir, sprintf('lineErrorSamEn_%s', chanStr));
    h = errorbar(dataMN, dataSE);
    % [hbar, herr] = barwitherr(dataSE', dataMN');
    set(h, 'linewidth', 2);
    YLIM = ylim;
    ylim([0+2 YLIM(2)]);
    set(gca, 'xticklabel', tagStates, 'xtick', [1:4]);
    set(gcf, 'color', 'w');
    title(sprintf('Sample entropy'));

    print(gcf, '-djpeg', '-cmyk', '-painters', ...
          strcat(fn, '.jpg'));
    print(gcf, '-depsc', '-painters', ...
          strcat(fn, '.eps'));

    %% Delta/alpha
    DAPlot = squeeze(mean(Pow.DA(:, indChan, :), 2));
    dataMN = squeeze(mean(DAPlot, 2));
    dataSE = std(DAPlot,1,2)/sqrt(size(DAPlot,2));

    fn = fullfile(outDir, sprintf('lineErrorPowRatio_DA_%s', chanStr));
    h = errorbar(dataMN, dataSE);
    % [hbar, herr] = barwitherr(dataSE', dataMN');
    set(h, 'linewidth', 2);
    YLIM = ylim;
    ylim([0 YLIM(2)]);
    set(gca, 'xticklabel', tagStates, 'xtick', [1:4]);
    set(gcf, 'color', 'w');
    title(sprintf('Power Ratio: Delta/Alpha'));

    print(gcf, '-djpeg', '-cmyk', '-painters', ...
          strcat(fn, '.jpg'));
    print(gcf, '-depsc', '-painters', ...
          strcat(fn, '.eps'));

    %% Delta+theta / alpha+theta


    DTATPlot = squeeze(mean(Pow.DTAT(:, indChan, :), 2));
    dataMN = squeeze(mean(DTATPlot, 2));
    dataSE = std(DTATPlot,1,2)/sqrt(size(DTATPlot,2));

    fn = fullfile(outDir, sprintf('lineErrorPowRatio_DTAT_%s', chanStr));
    h = errorbar(dataMN, dataSE);
    % [hbar, herr] = barwitherr(dataSE', dataMN');
    set(h, 'linewidth', 2);
    YLIM = ylim;
    ylim([0 YLIM(2)]);
    set(gca, 'xticklabel', tagStates, 'xtick', [1:4]);
    set(gcf, 'color', 'w');
    title(sprintf('Power Ratio: (Delta+Theta)/(Alpha+Theta)'));

    print(gcf, '-djpeg', '-cmyk', '-painters', ...
          strcat(fn, '.jpg'));
    print(gcf, '-depsc', '-painters', ...
          strcat(fn, '.eps'));

    %% Delta+theta / alpha+beta


    DTABPlot = squeeze(mean(Pow.DTAB(:, indChan, :), 2));
    dataMN = squeeze(mean(DTABPlot, 2));
    dataSE = std(DTABPlot,1,2)/sqrt(size(DTABPlot,2));

    fn = fullfile(outDir, sprintf('lineErrorPowRatio_DTAB_%s', chanStr));
    h = errorbar(dataMN, dataSE);
    % [hbar, herr] = barwitherr(dataSE', dataMN');
    set(h, 'linewidth', 2);
    YLIM = ylim;
    ylim([0 YLIM(2)]);
    set(gca, 'xticklabel', tagStates, 'xtick', [1:4]);
    set(gcf, 'color', 'w');
    title(sprintf('Power Ratio: (Delta+Theta)/(Alpha+Beta)'));

    print(gcf, '-djpeg', '-cmyk', '-painters', ...
          strcat(fn, '.jpg'));
    print(gcf, '-depsc', '-painters', ...
          strcat(fn, '.eps'));

end
close all
