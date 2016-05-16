clear erspData erspData2
% Elem = {'Fz'};
% Elem = {'F1'};
% Elem = {'F3'};
% Elem = {'F2'};
% Elem = {'FCz'};
% Elem = {'Cz'};
% Elem = {'CPz'};
% Elem = {'Pz'};
% Elem = {'POz'};
% Elem = {'Oz'};
Elem = {'CP1'};
% Elem = 12;
% Elem = {'C3', 'C1', 'Cz', 'C2', 'C4'};
% Elem = {'F1', 'Fz', 'F2'};
% Elem = {'C3', 'C1'};
% Elem = {'C2', 'C4'};
% Elem = {'P4', 'P6', 'P8', 'PO4', 'PO8', 'O2'};
% Elem = {'P1', 'Pz', 'P2', 'PO3', 'POz', 'PO4', 'Oz'};
range = [-200 1400 3 100];
CLIM = [-4, 4];
YLIM = [4 30];
% YTICKS = [30:10:100];
YTICKS = [4 6 8 10 12 14 16 20 25 30];
% YTICKS = [3,10:10:100];
% effectType = 3;
% statistics
method = 'param';
naccu = 200;
alpha = 0.05;
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
% get threshold
data = {erspData2{1}, erspData2{3}, erspData2{5}; ...
        erspData2{2}, erspData2{4}, erspData2{6}};
[stats, df, pvals] = statcond( data, ...
                               'paired', 'on', ...
                               'method', method);
for iThresh = 1:3
    threshNeg = pvals{iThresh}>alpha;
    threshPos = pvals{iThresh}<alpha;
    pvals{iThresh}(threshNeg) = 0;
    pvals{iThresh}(threshPos) = 1;
end
% B = bwconncomp(pvals{3});
% get mean
erspMean = cellfun(@(x) {squeeze(mean(x, 3))}, erspData2);
% make subplot column-wise
idx = reshape(1:6,2,[])';
idx = idx(:);
% plot now
figure('color', 'white', 'paperunits', 'normalized');
for iSubplot = 1:numel(titles)
    fprintf('%s', iSubplot)
    subplot_tight(2, 3, iSubplot, [0.1 0.1]);
    contourf(times, freqs, erspMean{idx(iSubplot)}, 40, ...
             'linestyle', 'none');
    axis square
    set(gca,'clim', CLIM, 'xlim', [-200 1400], ...
            'ylim', YLIM, 'xtick', xticks, 'ytick', yticks);
    title(titles{iSubplot}, 'fontsize', 12)
    xlabel('Time (ms)', 'fontsize', 12), ...
        ylabel('Frequency (Hz)', 'fontsize', 12)
    hold on;
    plot([0 4 0 30], ':b', 'linewidth', 0.5)
    contour(times, freqs, pvals{1}, ...
            'color', 'k', 'linewidth', 1);
    contour(times, freqs, pvals{2}, ...
            'color', 'g', 'linewidth', 1);
    contour(times, freqs, pvals{3}, ...
            'color', 'r', 'linewidth', 1);
    %     legend({'Pain Main Effect', 'Mood Main Effect', 'Interaction Effect'})
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