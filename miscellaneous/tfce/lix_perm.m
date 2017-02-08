%% using permutation for computing t/F values & tfce for multiple comparison correction
% 1. permutation testing using 'statcond'
% 2. tfce using 'limo_tfce'

%% parameters
c = {'C3'};
subbase = 'on';
nPermutes = 200;

%% study parameters
% check study design

%% check if channels or clusters
if iscellstr(c)
        ChanOrClust = 'channels';
        if numel(c)==1
            chanName = c{1};
        elseif numel(c)>=2
            chanName = cellstrcat(c, '-');
        end
        filename_prefix = ['chan', chanName];
elseif isnumeric(c)
        ChanOrClust = 'clusters';
        filename_prefix = ['clust', int2str(c)];
end
%% compute erspData
[STUDY, erspData, erspTimes, erspFreqs] = ...
    std_erspplot(STUDY, ALLEEG, ...
                 'plotsubjects', 'off', ...
                 ChanOrClust, c, ...
                 'plotmode', 'none', ...
                 'subbaseline', subbase);

if strcmpi(ChanOrClust, 'channels')
    subj = STUDY.subject;
    if ndims(erspData{1})==4
        erspData = cellfun(@(x) {squeeze(mean(x, 3))}, erspData);
    end
elseif strcmpi(ChanOrClust, 'clusters')
    setInds = STUDY.cluster(c).setinds;
    subj = STUDY.subject(unique(setInds{1}));
    erspData = mergeComponentsInOneSubjOneClust(erspData, setInds);
end

%% reshape data

erspData = reshape(erspData, [2,3]); % 1d: pain; 2d: mood;

% statistics
[stats, df, pvals] = statcond(erspData, ...
                              'paired', 'on', ...
                              'method', 'perm', ...
                              'naccu', nPermutes, ...
                              'arraycomp', 'off');

%% tfce
tfce_score_inter = limo_tfce(2, stats{3}, [], 1);
% tfce_score_pain = limo_tfce(2, stats{1}, [], 1);
% tfce_score_mood = limo_tfce(2, stats{2}, [], 1);

%% plot
fig = figure;
subplot(121);
contourf(erspTimes, erspFreqs, stats{3}, 40, 'LineStyle', 'none');
axis square;
set(gca, 'ylim', [3 30], 'xlim', [-200 1400]);
subplot(122);
contourf(erspTimes, erspFreqs, tfce_score_inter, 40, 'LineStyle', 'none');
axis square;
set(gca, 'ylim', [3 30], 'xlim', [-200 1400]);
