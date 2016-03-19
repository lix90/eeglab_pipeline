inDir = '~/Data/dingyi/output_noRemoveWindows_1hz/';
outDir = '~/Data/dingyi/image_noRemoveWindows_1hz/';

load(fullfile(inDir, 'Pow.mat'));
load(fullfile(inDir, 'samEn.mat'));
load(fullfile(inDir, 'chanlocs.mat'));

%% relative power

chan = {'CZ'};
tagBands = Pow.tagBands(1:5);
tagStates = Pow.tagStates;
indChan = ismember({chanlocs.labels}, chan);

relPlot = squeeze(mean(Pow.Rel(:, 1:5, indChan, :), 3));
dataMN = squeeze(mean(relPlot, 3));
dataSE = std(relPlot,1,3)/sqrt(size(relPlot,3));

h = errorbar(dataMN, dataSE);
% [hbar, herr] = barwitherr(dataSE', dataMN');
set(h, 'linewidth', 2);
set(gca, 'xticklabel', tagStates, 'xtick', [1:4]);
set(gcf, 'color', 'w');
legend(h, 'string', tagBands, 'location', 'SouthEastOutside');
title('Relative Power');
ylabel('Relative Power');

%% sample entropy

chan = {'CZ'};
tagBands = Pow.tagBands(1:5);
tagStates = Pow.tagStates;
indChan = ismember({chanlocs.labels}, chan);

SEPlot = squeeze(mean(sampleEn.data(:, indChan, :), 2));
dataMN = squeeze(mean(SEPlot, 2));
dataSE = std(SEPlot,1,2)/sqrt(size(SEPlot,2));

h = errorbar(dataMN, dataSE);
% [hbar, herr] = barwitherr(dataSE', dataMN');
set(h, 'linewidth', 2);
set(gca, 'xticklabel', tagStates, 'xtick', [1:4]);
set(gcf, 'color', 'w');
% legend(h, 'string', tagBands, 'location', 'SouthEastOutside');
% title('Relative Power');
% ylabel('Relative Power');

%% Delta/alpha

chan = {'CZ'};
tagBands = Pow.tagBands(1:5);
tagStates = Pow.tagStates;
indChan = ismember({chanlocs.labels}, chan);

DAPlot = squeeze(mean(Pow.DA(:, indChan, :), 2));
dataMN = squeeze(mean(DAPlot, 2));
dataSE = std(DAPlot,1,2)/sqrt(size(DAPlot,2));

h = errorbar(dataMN, dataSE);
% [hbar, herr] = barwitherr(dataSE', dataMN');
set(h, 'linewidth', 2);
set(gca, 'xticklabel', tagStates, 'xtick', [1:4]);
set(gcf, 'color', 'w');
% legend(h, 'string', tagBands, 'location', 'SouthEastOutside');
% title('Relative Power');
% ylabel('Relative Power');

%% Delta+theta / alpha+theta

chan = {'CZ'};
tagBands = Pow.tagBands(1:5);
tagStates = Pow.tagStates;
indChan = ismember({chanlocs.labels}, chan);

DTATPlot = squeeze(mean(Pow.DTAT(:, indChan, :), 2));
dataMN = squeeze(mean(DTATPlot, 2));
dataSE = std(DTATPlot,1,2)/sqrt(size(DTATPlot,2));

h = errorbar(dataMN, dataSE);
% [hbar, herr] = barwitherr(dataSE', dataMN');
set(h, 'linewidth', 2);
set(gca, 'xticklabel', tagStates, 'xtick', [1:4]);
set(gcf, 'color', 'w');
% legend(h, 'string', tagBands, 'location', 'SouthEastOutside');
% title('Relative Power');
% ylabel('Relative Power');

%% Delta+theta / alpha+theta

chan = {'CZ'};
tagBands = Pow.tagBands(1:5);
tagStates = Pow.tagStates;
indChan = ismember({chanlocs.labels}, chan);

DTABPlot = squeeze(mean(Pow.DTAB(:, indChan, :), 2));
dataMN = squeeze(mean(DTABPlot, 2));
dataSE = std(DTABPlot,1,2)/sqrt(size(DTABPlot,2));

h = errorbar(dataMN, dataSE);
% [hbar, herr] = barwitherr(dataSE', dataMN');
set(h, 'linewidth', 2);
set(gca, 'xticklabel', tagStates, 'xtick', [1:4]);
set(gcf, 'color', 'w');
% legend(h, 'string', tagBands, 'location', 'SouthEastOutside');
% title('Relative Power');
% ylabel('Relative Power');
