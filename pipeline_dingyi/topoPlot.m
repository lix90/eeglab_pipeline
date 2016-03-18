inDir = '~/Data/dingyi/output_noRemoveWindows_1hz/';
outDir = '~/Data/dingyi/image_noRemoveWindows_1hz/';

load(fullfile(inDir, 'dingyi_specdata.mat'));

TITLE = sprintf('%s', band);
LINEWIDTH = 4;
YLABEL = 'Relative Power (dB)';
COLOR = 'r';

tagBands = out.tagBands;
tagStates = out.tagStates;
chanlocs = out.chanlocs;

for i = 1:numel(tagBands)
    
    dataSubset = squeeze(mean(out.specdata(i, :, :, :), 4));
    dataplot = {squeeze(dataSubset(1,:)), ...
                squeeze(dataSubset(2,:)), ...
                squeeze(dataSubset(3,:)), ...
                squeeze(dataSubset(4,:))};
    std_chantopo(dataplot,'chanlocs', chanlocs,...
                 'datatype', 'spec',...
                 'titles', tagStates);
    set(gcf, 'name', tagBands(i));
    % h = errorbar(dataMN, dataSE);
    % set(h, 'linewidth', LINEWIDTH, 'color', COLOR);
    % set(gca, 'xticklabel', tagStates, 'xtick', [1:4]);
    % set(gcf, 'color', 'w');
    % title(TITLE);
    % ylabel(YLABEL);
end
