% NUMorNAME = 9; 
% NUMorNAME = {'Oz'};
% NUMorNAME = {'F1', 'Fz', 'F2'};
% NUMorNAME = {'P4', 'P6', 'P8', 'PO4', 'PO8', 'O2'};
NUMorNAME = {'P1', 'Pz', 'P2', 'PO3', 'POz', 'PO4', 'Oz'};
% NUMorNAME = {'AF3', 'F5', 'F3', 'F1'};
% NUMorNAME = {'CP6'};
ERPorERSP = 1;
PARAMorPERM = 1;  % 1=param/2=perm
PLOTTYPE = 1; %1=all apart;2=condition together;3=group together
PLOTSTD = 'off';
ALPHA = 0.05;
% load study
% CONDS = {'Neg_Pain' 'Neg_noPain' 'Neu_Pain' ...
% 		 'Neu_noPain' 'Pos_Pain' 'Pos_noPain'};
% CONDS = {'Neg_Pain' 'Neg_noPain'};
% CONDS = {'Pos_Pain', 'Pos_noPain'};
% CONDS = {'Neu_Pain', 'Neu_noPain'};

CONDS = {'Adult_Pain' 'Adult_noPain' 'Child_Pain' ...
		 'Child_noPain' 'Old_Pain' 'Old_noPain'};
% load study
% studyName = 'mood_pain_3_backproj.study';
% studyName = 'age_pain_empathy_backproj.study';
% studyDir = '~/Documents/data/iris/backproj';
studyName = 'mood_pain_mni_backproj.study';
studyDir = '~/Documents/data/backproj_mni';
if ~any(strcmp(who, 'STUDY')) || isempty(STUDY)
    [STUDY ALLEEG] = pop_loadstudy('filename', studyName, 'filepath', studyDir);
    [STUDY ALLEEG] = std_checkset(STUDY, ALLEEG);
    CURRENTSTUDY = 1; 
    EEG = ALLEEG; 
    CURRENTSET = 1:length(EEG);
end
if ~isequal(STUDY.design.variable(1).value, CONDS)
    STUDY = std_makedesign(STUDY, ALLEEG, 1, ...
                           'variable1', 'type', 'pairing1', 'on', ...
                           'values1', CONDS);
    STUDY = pop_savestudy(STUDY, EEG, 'savemode', 'resave');
end

%%%%%%%%%%%%%%%%%%%
% compute ERP
%%%%%%%%%%%%%%%%%%%

if iscellstr(NUMorNAME)
		TYPENAME = 'channels';
elseif isnumeric(NUMorNAME)
		TYPENAME = 'clusters';
end
STUDY = pop_statparams(STUDY, 'condstats','on','alpha', ALPHA);
% compute
switch ERPorERSP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% erp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 1
        clear erpData erpData2
        [STUDY, erpData, erpTimes] = std_erpplot(STUDY, ALLEEG, ...
            TYPENAME, NUMorNAME, ...
            'noplot', 'on', 'filter', 15, 'averagechan', 'on');
        % merge when is computed on clusters
        if strcmpi(TYPENAME, 'clusters')
            setInds = STUDY.cluster(NUMorNAME).setinds;
            erpData2 = mergeComponentsInOneSubjOneClust(erpData, setInds);
        elseif strcmpi(TYPENAME, 'channels')
            if ndims(erpData{1})==3
                erpData2 = cellfun( @(x) {squeeze(mean(x, 2))} , erpData);
            else
                erpData2 = erpData;
            end
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ersp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 2
        clear erspData erspData2
        [STUDY, erspData, erspTimes, erspFreqs] = ...
            std_erspplot(STUDY, ALLEEG, ...
            'plotsubjects', 'off', ...
            TYPENAME, NUMorNAME,...
            'plotmode', 'none',...
            'subbaseline', 'on');
        if strcmpi(TYPENAME, 'channels')
            if size(erspData{1})==4
                erspData2 = cellfun(@(x) {squeeze(mean(x,3))}, erspData);
            elseif size(erspData{1})==3
                erspData2 = erspData;
            end
        end
        if strcmpi(TYPENAME, 'clusters')
            setInds = STUDY.cluster(NUMorNAME).setinds;
            erspData2 = mergeComponentsInOneSubjOneClust(erspData, setInds);
        end
end
% statistics erp
data = {erpData2{1}, erpData2{3}, erpData2{5};...
        erpData2{2}, erpData2{4}, erpData2{6}}; % 2(conds)*3(groups)
switch PARAMorPERM
    case 1 % parameters
        [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
            std_stat(data, 'groupstats', 'on', 'condstats', 'on', ...
                    'method', 'parametric');
    case 2 % permutation
        [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
                std_stat(data, 'groupstats', 'on', 'condstats', 'on', ...
                        'method', 'permutation', 'naccu', 200);
end
% [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
% 			std_stat(data, 'mode', 'fieldtrip', ...
% 			'fieldtripmethod', 'montecarlo', 'naccu', 200, ...
% 			'alpha', 0.05, 'fieldtripmcorrect', 'cluster', ...
% 			'groupstats', 'on', 'condstats', 'on');
% plot ERP
switch PLOTTYPE
    case 1 %apart
        std_plotcurve(erpTimes, data, 'datatype', 'erp', ...
                    'groupstats', pgroup, 'condstats', pcond, ...
                    'interstats', pinter, ...
                    'plotgroups', 'apart', 'plotconditions', 'apart',...
                    'legend', 'on', 'plotstderr', PLOTSTD, 'plotdiff', 'off');
    case 2 %group apart
        std_plotcurve(erpTimes, data, 'datatype', 'erp', ...
                    'condstats', pcond, ...
                    'plotgroups', 'apart', 'plotconditions', 'together',...
                    'legend', 'on', 'plotstderr', PLOTSTD, 'plotdiff', 'off');
    case 3 %cond apart
        std_plotcurve(erpTimes, data, 'datatype', 'erp', ...
                    'groupstats', pgroup, ...
                    'plotgroups', 'together', 'plotconditions', 'apart',...
                    'legend', 'on', 'plotstderr', PLOTSTD, 'plotdiff', 'off');
end
% std_plotcurve(erpTimes, data, 'datatype', 'erp', ...
% 			'plotgroups', 'together', 'plotconditions', 'together',...
%             'legend', 'on', 'plotstderr', 'off', 'plotdiff', 'on');
% edit plot
% h = get(gcf, 'children');
% Nh = numel(h);
% for i = 1:Nh
%    hNow = axes(h(i));
%    hold on
%    plot([0 0], get(gca('ylim')), ':b')
%    plot(get(gca, 'xlim'), [0 0], ':b')
%    hold off
% end
%% ERP diff
clear data
data = {erpData2{1}-erpData2{2}... 
        erpData2{3}-erpData2{4}...
        erpData2{5}-erpData2{6}};
[pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
    std_stat(data, 'groupstats', 'on', ...
			'method', 'permutation', 'naccu', 500);
std_plotcurve(linspace(-200, 1000, size(data{1},1)), data, 'datatype', 'erp', ...
            'groupstats', pgroup, ...
			'plotgroups', 'together',...
            'legend', 'on', 'plotstderr', PLOTSTD, 'plotdiff', 'off');
hold on;
plot(get(gca, 'xlim'), [0 0], '--b', 'linewidth', 1)
plot([0 0], get(gca, 'ylim'), '--b', 'linewidth', 1)
% findobj(gca, 'type', 'line', 'linestyle', '-')

%% plot ersp image with threshold
titles = {'Negative Pain', 'Neutral Pain', 'Positive Pain', ...
          'Negative noPain', 'Neutral noPain', 'Positive noPain'};
yticks = [4 8 13 30];
xticks = 0:200:1000;
% get threshold
data = {erspData2{1}, erspData2{3}, erspData2{5}; ... 
		erspData2{2}, erspData2{4}, erspData2{6}};
[stats, df, pvals] = statcond( data, ...
	'paired', 'on', ...
	'method', 'param');
for iThresh = 1:3
    threshNeg = pvals{iThresh}>0.05;
    threshPos = pvals{iThresh}<0.05;
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
	contourf(times, freqs, erspMean{idx(iSubplot)}, 50, ...
        'linestyle', 'none');
    axis square
	set(gca,'clim', [-3 3], 'xlim', [-200 1200], ...
        'ylim', [4 30], 'xtick', xticks, 'ytick', yticks);
	title(titles{iSubplot}, 'fontsize', 12)
	xlabel('Time (ms)', 'fontsize', 12), ...
        ylabel('Frequency (Hz)', 'fontsize', 12)
    hold on;
    plot([0 4 0 30], ':b', 'linewidth', 0.5)
    contour(times, freqs, pvals{1}, ...
        'color', 'k');
    contour(times, freqs, pvals{2}, ...
        'color', 'g');
    contour(times, freqs, pvals{3}, ...
        'color', 'r');
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
    endscript