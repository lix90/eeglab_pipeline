%% script for exporting ersp

%% parameters
% defining ROIs
chanLabels = {'F4'}; % channel labels of interest
timeRange = [200 600]; % time range of erp component
freqRange = [4, 7];
outDir = ''; % output directory
subjExclude = {};

%% compute erp
subj = STUDY.subject;
if ~isempty(subjExclude)
    subj = subj(~ismember(subj, subjExclude));
end
var = STUDY.design(1).variable(1).value;

if ~exist(outDir, 'dir'); mkdir(outDir); end
[STUDY, erspData, erspTimes, erspFreqs] = ...
    std_erspplot(STUDY, ALLEEG, ...
                 'plotsubjects', 'off', 'channels', chanLabels,...
                 'plotmode', 'none',...
                 'subbaseline', 'on');% subbaseline 'on' or 'off'?

% time & freq index
t = dsearchn(erspTimes', timeRange');
f = dsearchn(erspFreqs', freqRange');
% prepare output name
timeStr = strcat('t', strjoin(timeRange, '-'));
freqStr = strcat('f', strjoin(freqRange, '-'));
chanStr = strjoin(chanLabels, '-');
fname = strcat('ersp_', chanStr, '_', freqStr, '_',  timeStr, '.csv');
fnameFull = fullfile(outputDir, fname);
header = strcat('subject,', strjoin(var, ','), '\n');

fid = fopen(fnameFull, 'w');
fprintf(fid, header);

for i_s = 1:numel(subj)
    fprintf(fid, [subj{i_s}, ',']);
    erspStr = [];
    for i_v = 1:numel(var)
        erspTmp = mean(mean(mean(erspData{i_v}(f(1):f(2), t(1):t(2), :, i_s),1),2),3);
        erspStr = [erspStr, {num2str(erspTmp)}];
    end % within var end
        fprintf(fid, strcat(strjoin(erspStr, ','), '\n'));
end % subj loop end
    fclose(fid);
