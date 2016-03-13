% script_ersp_wave_statistics
Type = 2; %1='channels'/1='clusters'
Elem = 9;
% Elem = {'C1'};
method = 'param';
conditions = {'Negative Mood', 'Neutral Mood', 'Positive Mood'};
rhythms = {'theta1', 'theta2', 'alpha1', 'alpha2', 'beta', 'gammalow', 'gammahigh'};
frexRange = {[3 5],[5 7], [8 10], [11 13], [14 24], [25 40], [60 80]}; % theta, alpha, beta, gamma
colors = {'b', 'g', 'r'};

% compute ersp
switch Type
    case 1
        TypeName = 'channels';
%         ElemInd = Elem;
%         ElemInd = lix_elecfind(chanLabels, Elem);
    case 2
        TypeName = 'clusters';
%         ElemInd = Elem;
end
[STUDY, erspData, erspTimes, erspFreqs] = std_erspplot(STUDY, ALLEEG, ...
						'plotsubjects', 'off', ...
						TypeName, Elem,...
                        'plotmode', 'none',...
                        'subbaseline', 'on');
% allocate variables
% conditions = STUDY.design.variable(1).value; 
times = erspTimes;
freqs = erspFreqs;
if Type==1
    erspData2 = cellfun(@(x) {squeeze(mean(x,3))}, erspData);
end
if Type==2
    setInds = STUDY.cluster(Elem).setinds;
    erspData2 = mergeComponentsInOneSubjOneClust(erspData, setInds);
end
% get wave
erspWave = export_ersp_wave(erspData2, freqs, frexRange);
% compute difference value
erspDiff{1} = erspWave{1}-erspWave{2}; % Negative
erspDiff{2} = erspWave{3}-erspWave{4}; % Neutral
erspDiff{3} = erspWave{5}-erspWave{6}; % Positive
erspWaveMean = cellfun(@(x) {squeeze(mean(x, 3))}, erspDiff);
dataDiff = {erspDiff{1}, erspDiff{2}, erspDiff{3}};

%%
titles = merge_cellstr(conditions, rhythms, ': ');
for iRhythm = 1:numel(rhythms)
	figure('name', rhythms{iRhythm}, 'color', 'white')
	hSubplot.(rhythms{iRhythm})(1) = subplot(2,1,1);
	for iPlot = 1:numel(conditions)
		plot(times, erspWaveMean{iPlot}(iRhythm,:), colors{iPlot}, 'LineWidth', 2);
		title(titles{iPlot, iRhythm});
	      hold on
	end
	xlabel('Time (ms)');
	ylabel('Power: Pain-noPain (dB)');
    legend(conditions, 'location', 'NorthEast');
	if ishold; hold off; end
	hSubplot.(rhythms{iRhythm})(2) = subplot(2,1,2);
	plot(times, pDiff.(rhythms{iRhythm})(iRhythm,:), 'k', 'linewidth', 2); ylim([0 0.1])
	xlabel('Time (ms)');
	ylabel('p values');
end
%% plot
[pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
    std_stat(dataDiff, 'groupstats', 'on', ...
			'method', 'permutation', 'naccu', 500);
std_plotcurve(erspTimes, data, 'datatype', 'spec', ...
            'groupstats', pgroup, ...
            'plotgroups', 'together',...
            'legend', 'on', 'plotstderr', 'on', 'plotdiff', 'on');
%% plot data down sampled
[pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
    std_stat(dataDiff, 'groupstats', 'on', ...
			'method', 'permutation', 'naccu', 500);
tmp = pgroup{1};
tmp(tmp>0.05)=1;
pgroup{1} = tmp; 
std_plottf(erspTimes, 1:numel(rhythms), dataDiff, 'groupstats', pgroup);
%% 
TITLES = {'Negative Mood', 'Neutral Mood', 'Positive Mood', ''};
data = {erspWave{1}, erspWave{3}, erspWave{5};...
        erspWave{2}, erspWave{4}, erspWave{6}};
[pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
    std_stat(data, 'groupstats', 'on', 'condstats', 'on', ...
			'method', 'permutation', 'naccu', 500);
%
% tmp = pgroup{1};
% tmp(tmp>0.05)=1;
% pgroup{1} = tmp; 
std_plottf(erspTimes, 1:numel(rhythms), data, 'groupstats', pgroup, ...
    'condstats', pcond, 'interstats', pinter);
