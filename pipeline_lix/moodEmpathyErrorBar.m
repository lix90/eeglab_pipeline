% theta: 5.5-7.5Hz, 500-600ms
% alpha: 10.5-12Hz, 850-950ms
% beta: 18-20Hz, 500-600ms
%% prepare input parameters
indir = '~/data/adolesvsadult/conditiondata/';
outdir = fullfile(indir, 'image');

alpha = [8, 12, 400, 800];
beta = [13, 20, 300, 700];
chan = {'C3', 'C1', 'Cz', 'C2', 'C4'};
% chan = {'O1', 'Oz', 'O2'};
band = {'alpha', 'beta'};
LEGEND = {'non-Painful', 'Painful'};
XTICKLABEL = {'Negative', 'Neutral', 'Positive'};
YLABEL = 'ERSP (dB)';
if ~exist(outdir, 'dir'); mkdir(outdir); end
if numel(band)==2
    WIDTH = 20;
    HEIGHT = 10;
elseif numel(band)==1
    WIDTH = 10;
    HEIGHT = 10;
end
figure('color', 'w', ...
       'nextplot', 'add', ...
       'PaperUnits', 'centimeters', ...
       'PaperPositionMode', 'manual', ...
       'papersize', [WIDTH, HEIGHT], ...
       'PaperPosition', [0 0 WIDTH HEIGHT]);
for i = 1:numel(band)
    subplot(1, numel(band), i);
    roi = eval(band{i}); % or alpha & beta
    TITLE = {sprintf('Errorbar (stderr) of %s %s', ...
                     band{i}, cellstrcat(chan, '-'))};
    f = dsearchn(freqs', roi(1:2)');
    t = dsearchn(times', roi(3:4)');
    c = find(ismember(chans, chan));
    dataSubset = ...
        cellfun(@(x) {squeeze(mean(mean(x(f(1):f(2), t(1):t(2), c, :), 1), ...
                                   2))}, data);
    dataMN = cellfun(@(x) mean(x, 2), dataSubset, 'UniformOutput', false);
    dataSE = cellfun(@(x) std(x, 1, 2)/sqrt(size(x, 2)), dataSubset, ...
                     'UniformOutput', false);
    % plot
    [hbar, herr] = barwitherr(dataSE', dataMN');
    % set(hbar, 'EdgeColor', 'w');
    set(herr, 'LineWidth', 1, 'Color', 'k');
    set(gca, 'XTickLabel', XTICKLABEL);
    title(TITLE);
    if i == 1
        ylabel(YLABEL);
    end
    YLIM = ylim;
    switch band{i}
      case 'theta'
        ylim([YLIM(1), YLIM(2)+0.5]);
      case 'alpha'
        ylim([YLIM(1)-0.5, YLIM(2)]);
      case 'beta'
        ylim([YLIM(1)-0.5, YLIM(2)]);
    end
    if strcmp(band{i}, 'alpha') || strcmp(band{i}, 'beta')
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
