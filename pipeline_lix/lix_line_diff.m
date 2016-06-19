%% script for plot diff line
chanLabels = {'Cz', 'C3', 'C4'};
timeRange = [0, 1000];
freqRange = [8, 13];
outDir = '~/Desktop/paper/';

%% load study first & compute ersp
[~, erspData, erspTimes, erspFreqs] = ...
    std_erspplot(STUDY, ALLEEG, ...
                 'plotsubjects', 'off', 'channels', chanLabels,...
                 'plotmode', 'none', 'subbaseline', 'off');
subj = STUDY.subject;
EXCLUDE = {'chenxu', 'chenyanqiu', 'dairubiao', ...
          'xujin', 'pujianyong', 'yuanjianmei'};
subj = setdiff(subj, EXCLUDE);

t1 = find(erspTimes<=timeRange(1), 1, 'last');
t2 = find(erspTimes<=timeRange(2), 1, 'last');
f1 = find(erspFreqs<=freqRange(1), 1, 'last');
f2 = find(erspFreqs<=freqRange(2), 1, 'last');

ersp_subset = ...
    cellfun(@(x) {squeeze(mean(mean(mean(x(f1:f2, t1:t2, :, :), 1), 3), 4))}, ...
                      erspData);

diff_neg = ersp_subset{1,1}-ersp_subset{1,2};
diff_neu = ersp_subset{2,1}-ersp_subset{2,2};
diff_pos = ersp_subset{3,1}-ersp_subset{3,2};
time_subset = erspTimes(t1:t2);

%%
hf = figure('color', 'w', 'units', 'normalized');
ha = axes('position', [0.15, 0.3, 0.8, 0.5], 'parent', hf);

plot(time_subset, diff_neg, 'b');
hold on;
plot(time_subset, diff_neu, 'k');
plot(time_subset, diff_pos, 'r');

hold off;
set(gca, 'xlim', [0, 1000], 'ylim', [-1.5, 0.5], 'linewidth', 2, ...
         'xcolor', [0,0,0]+0.1, 'box', 'off')
h_children = get(gca, 'children');
set(h_children(1), 'linewidth', 3);
set(h_children(2), 'linestyle', ':', 'linewidth', 3);
set(h_children(3), 'linestyle', '-.', 'linewidth', 3);
ylabel('Differetial mu suppression', 'fontsize', 12);
xlabel('Time (ms)', 'fontsize', 12);
title(sprintf('Pain empathy effects among mood conditions\naveraged at 3 electrodes'));
hl = legend({'Negative', 'Neutral', 'Positive'}, ...
            'position', [0.2, 0.1, 0.5, 0.1],...
            'orientation', 'horizontal',...
            'box', 'off', 'xcolor', 'w', 'ycolor', 'w');
line([0,1000], [0, 0], 'color', [0.5, 0.5, 0.5],...
     'linewidth', 2, 'parent', ha, 'linestyle', '--');

