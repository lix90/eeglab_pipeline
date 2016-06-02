%% script for doing statistics on erspdata
% define ROI
Frontal = {};
LeftFrontal = {};
RightFrontal = {};
Central = {};
LeftCentral = {};
RigthCentral = {};
Posterior = {};
LeftPosterior = {};
RightPosterior = {};
Mu = {'C3', 'C1', 'Cz', 'C2', 'C4'};
FMtheta = {'F1', 'Fz', 'F2'};
LMu  = {'C3', 'C1'};
RMu = {'C2', 'C4'};

c = ;

%% plot parameters
range = [-200 1200 3 100];
CLIM = [-5, 5];
XLIM = [-200 1400];
YLIM = [3 30];
xticks = 0:200:1000;
yticks = [4 8 10 12 14 15 20 25 30];
% titles = {'Adult Pain', 'Child Pain', 'Old Pain', ...
%           'Adult noPain', 'Child noPain', 'Old noPain'};
titles = {'Negative Pain', 'Neutral Pain', 'Positive Pain', ...
          'Negative noPain', 'Neutral noPain', 'Positive noPain'};

%% statistics parameters
method = 'perm';
tfce = 'on';
naccu = 200;
alpha = 0.01;

%%
if isnumeric(c)
    TypeName = 'clusters';
elseif iscellstr(c)
    TypeName = 'channels';
end
clear erspData erspData2
[STUDY, erspData, erspTimes, erspFreqs] = ...
    std_erspplot(STUDY, ALLEEG, ...
                 'plotsubjects', 'off', ...
                 TypeName, c,...
                 'plotmode', 'none',...
                 'subbaseline', 'on');
times = erspTimes;
freqs = erspFreqs;
if strcmp(TypeName, 'channels')
    erspData2 = cellfun(@(x) {squeeze(mean(x,3))}, erspData);
elseif strcmp(TypeName, 'clusters')
    setInds = STUDY.cluster(c).setinds;
    erspData2 = mergeComponentsInOneSubjOneClust(erspData, setInds);
end

% plot ersp image with threshold

%% statistics
data = reshape(erspData2, [2,3]); % pain * mood
[stats, df, pvals] = statcond( data, ...
                               'paired', 'on', ...
                               'method', method, ...
                               'naccu', naccu);
%% tfce
if strcmp(tfce, 'on')
    tfce_inter = limo_tfce(2, stats{3}, [], 1);
end

% TODO: F value to p value

%% get mean
erspMean = cellfun(@(x) {squeeze(mean(x, 3))}, erspData2);

% make subplot column-wise
idx = reshape(1:6,2,[])';
idx = idx(:);

%% plot now
hFig = figure('color', 'white', 'paperunits', 'normalized');
for iSubplot = 1:numel(titles)
    fprintf('%s', iSubplot)
    subplot_tight(2, 3, iSubplot, [0.1 0.1]);
    contourf(times, freqs, erspMean{idx(iSubplot)}, 40, ...
             'linestyle', 'none');
    axis square
    set(gca,'clim', CLIM, 'xlim', XLIM, ...
            'ylim', YLIM, 'xtick', xticks, 'ytick', yticks);
    title(titles{iSubplot}, 'fontsize', 12)
    xlabel('Time (ms)', 'fontsize', 12)
    ylabel('Frequency (Hz)', 'fontsize', 12)
    hold on;
    plot([0 4 0 30], ':b', 'linewidth', 0.5)
    contour(times, freqs, pvals{1}, ...
            'color', 'k');
    contour(times, freqs, pvals{2}, ...
            'color', 'g');
    contour(times, freqs, pvals{3}, ...
            'color', 'r');
end
%% make plot nice
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
