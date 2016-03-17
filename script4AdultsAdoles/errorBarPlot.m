% theta: 5.5-7.5Hz, 500-600ms
% alpha: 10.5-12Hz, 850-950ms
% beta: 18-20Hz, 500-600ms
%% prepare input parameters
indir = '~/data/adolesvsadult/conditiondata/';
outdir = '~/data/adolesvsadult/conditiondata/ersp/image/'
theta = [5.5, 7.5, 500, 600];
alpha = [10.5, 12, 850, 950];
beta = [18, 20, 500, 600];
% plot
chan = {'F3', 'Fz', 'F4', 'FC3', 'FCz', 'FC4',...
        'C3', 'Cz', 'C4', 'CP3', 'CPz', 'CP4'};
% chan = {'PO7', 'PO8', 'PO3', 'PO4', 'POz', ...
%         'Oz', 'O1', 'O2'};
band = {'theta', 'beta'};
% band = {'alpha'};
LEGEND = {'High', 'Medium', 'Neutral'};
XTICKLABEL = {'Adults', 'Adolescents'};
YLABEL = 'ERSP (dB)';
if numel(band)==2
    WIDTH = 20;
    HEIGHT = 10;
elseif numel(band)==1
    WIDTH = 10;
    HEIGHT = 10;
end
for j = 1:numel(chan)
    figure('color', 'w', ...
           'nextplot', 'add', ...
           'PaperUnits', 'centimeters', ...
           'PaperPositionMode', 'manual', ...
           'papersize', [WIDTH, HEIGHT], ...
           'PaperPosition', [0 0 WIDTH HEIGHT]);
    for i = 1:numel(band)
        subplot(1, numel(band), i);
        roi = eval(band{i}); % or alpha & beta
        TITLE = {sprintf('Errorbar (stderr) of %s %s', chan{j}, band{i})};
        f = dsearchn(freqs', roi(1:2)');
        t = dsearchn(times', roi(3:4)');
        chanNow = chan{j};
        c = find(ismember(chans, chanNow));
        dataSubset = ...
            cellfun(@(x) {squeeze(mean(mean(x(f(1):f(2), t(1):t(2), c, :), 1), 2))}, data);
        dataMN = cellfun(@mean, dataSubset);
        dataSE = cellfun(@(x) std(x)/sqrt(numel(x)), dataSubset);
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
    if strcmp(band{i}, 'alpha')
        outName = strcat('errBarSpec_', band{i}, '_', ...
                         num2str(roi(1)), '-', num2str(roi(2)), '_', ...
                         num2str(roi(3)), '-', num2str(roi(4)), '_', ...
                         chan{j});
    else
        outName = strcat('errBarSpec_theta-beta_', ...
                         num2str(roi(1)), '-', num2str(roi(2)), '_', ...
                         num2str(roi(3)), '-', num2str(roi(4)), '_', ...
                         chan{j});
    end
    print(gcf, '-djpeg', '-cmyk', '-painters', ...
          fullfile(outdir, strcat(outName, '.jpg')));
    print(gcf, '-depsc', '-painters', ...
          fullfile(outdir, strcat(outName, '.eps')));
end
close all
