% export erp
outDir = '~/Big/erp';
if ~exist(outDir, 'dir'); mkdir(outDir); end
% initiation
condSets = STUDY.design.variable(1).value;
chanSets = {'C1', 'C2', 'Cz', 'C3', 'C4'};
% S = STUDY.subject';
% compute
[STUDY, erpData, erpTimes] = std_erpplot(STUDY, ALLEEG, ...
            'channels', chanSets, ...
            'noplot', 'on', 'averagechan', 'on');
% Srepped = repmat(S, [size(erpData{1},1),1]);
erpData = cellfun(@(x) {mean(x, 2)}, erpData);
% dlwrite
% output.subject = S;
output.frames = erpTimes';
for iCond = 1:numel(condSets)
    condNow = condSets{iCond};
    output.(condNow) = erpData{iCond};
end
chanName = cellstrcat(chanSets, '-');
fileName = strcat('erp_', chanName, '.csv');
output_filename = fullfile(outDir, fileName);
struct2csv(output, output_filename);
disp('done')