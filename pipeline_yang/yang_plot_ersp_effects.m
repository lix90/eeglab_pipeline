%% script for plotting significant effect of mood on pain empathy
clear erspData2 data pvals
% plot parameters
Elem = {'C3'};
range = [-200 1400 3 100];
CLIM = [-4, 4];
YLIM = [3 35];
YTICKS = [4 6 8 10 12 14 20 25 30];
statMethod = 'param';
alpha = 0.05;

% compute
if iscellstr(Elem)
    TypeName = 'channels';
elseif isnumeric(Elem)
    TypeName = 'clusters';
end
[STUDY, erspData, erspTimes, erspFreqs] = ...
    std_erspplot(STUDY, ALLEEG, ...
                 'plotsubjects', 'off', ...
                 TypeName, Elem,...
                 'plotmode', 'none',...
                 'subbaseline', 'on');
times = erspTimes;
freqs = erspFreqs;
if strcmp(TypeName, 'channels')
    erspData2 = cellfun(@(x) {squeeze(mean(x,3))}, erspData);
elseif strcmp(TypeName, 'clusters')
    setInds = STUDY.cluster(Elem).setinds;
    erspData2 = mergeComponentsInOneSubjOneClust(erspData, setInds);
end

% plot ersp image with threshold
titles = {'Negative Pain', 'Neutral Pain', 'Positive Pain', ...
          'Negative noPain', 'Neutral noPain', 'Positive noPain'};
yticks = YTICKS;
xticks = 0:200:1400;

% statistics
data = {erspData2{1}, erspData2{3}, erspData2{5}; ...
        erspData2{2}, erspData2{4}, erspData2{6}};
[stats, df, pvals] = statcond( data, ...
                               'paired', 'on', ...
                               'method', statMethod);
erspMean = cellfun(@(x) {squeeze(mean(x, 3))}, erspData2);

% make subplot column-wise
idx = reshape(1:6, 2, [])';
idx = idx(:);

% plot now
figure('color', 'white', 'paperunits', 'normalized');

for iSubplot = 1:numel(titles)
    fprintf('%s', iSubplot)

    subplot_tight(2, 3, iSubplot, [0.05 0.06]);
    erspTemp = erspMean{idx(iSubplot)};
    erspTemp(pvals{3}>alpha) = 0;
    % contourf(times, freqs, erspTemp, 40, ...
    %          'linestyle', 'none');
    imagesclogy(times, freqs, erspTemp);
    axis square
    set(gca,'clim', CLIM, 'xlim', [-200 1400], ...
            'ylim', YLIM, 'xtick', xticks, 'ytick', yticks, ...
            'YDir', 'normal');
    title(titles{iSubplot}, 'fontsize', 12)
    xlabel('Time (ms)', 'fontsize', 12), ...
        ylabel('Frequency (Hz)', 'fontsize', 12)
    hold on;
    % plot([0 4 0 30], ':b', 'linewidth', 0.5);

end

% left, top, width, height
h = get(gcf, 'children');
for iHandle = 1:numel(h)
    if any(ismember([1 2 4 5], iHandle))
        hy = get(h(iHandle), 'ylabel');
        set(hy, 'visible', 'off')
        set(h(iHandle), 'ytick', [])
    end

    if any(ismember(4:6, iHandle))
        hx = get(h(iHandle), 'xlabel');
        set(hx, 'visible', 'off')
        set(h(iHandle), 'xtick', [])
    end
end

% main title
TITLE = sprintf('significant erea of ersp image of %s (unajusted)', ...
                char(Elem));
mtit(TITLE);