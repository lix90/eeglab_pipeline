function output = export_roi_clustersp(STUDY, erspData, erspTimes, erspFreqs, cluster, range)

conditions = STUDY.design.variable(1).value;
subjects = STUDY.subject;
times = erspTimes;
freqs = erspFreqs;
setInds = STUDY.cluster(cluster).setinds;
erspData2 = mergeComponentsInOneSubjOneClust(erspData, setInds);
subjects = subjects(unique(setInds{1}));
% find frequency and time index
[t,f] = lix_tfind(times, freqs, range);
Ncond = numel(conditions);
output = struct();
if size(subjects, 2) ~= 1; subjects = subjects'; end
output.Subject = subjects;
for i = 1:Ncond
	tmp = erspData2{i}(f(1):f(2), t(1):t(2), :);
	output.(conditions{i}) = squeeze(mean(mean(tmp,1),2));
end
% output = cell2mat(output);