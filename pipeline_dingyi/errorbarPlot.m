inDir = '~/Data/dingyi/output_noRemoveWindows_1hz/';
outDir = '~/Data/dingyi/image_noRemoveWindows_1hz/';

load(fullfile(inDir, 'dingyi_specdata.mat'));

chan = 'FZ';
band = 'beta';

TITLE = sprintf('%s %s', chan, band);
LINEWIDTH = 4;
YLABEL = 'Relative Power (dB)';
COLOR = 'r';

tagBands = out.tagBands;
tagStates = out.tagStates;
chanlocs = out.chanlocs;

indBand = ismember(tagBands, band);
indChan = ismember({chanlocs.labels}, chan);

dataSubset = squeeze(out.specdata(indBand, :, indChan, :));
dataMN = mean(dataSubset, 2);
dataSE = std(dataSubset,1,2)/sqrt(size(dataSubset,2));

h = errorbar(dataMN, dataSE);
set(h, 'linewidth', LINEWIDTH, 'color', COLOR);
set(gca, 'xticklabel', tagStates, 'xtick', [1:4]);
set(gcf, 'color', 'w');
title(TITLE);
ylabel(YLABEL);
