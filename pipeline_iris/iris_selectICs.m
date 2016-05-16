% std_selectICsByCluster

baseDir = 'E:\iris';
savePath = fullfile(baseDir, 'backproj_sph');
if ~exist(savePath, 'dir'); mkdir(savePath); end

clustInclude = [3:7,9:25,27:39,42];

nClust = numel(STUDY.cluster.child);
idxClust = 2:(nClust+1);
clustExclude = setdiff(idxClust, clustInclude);

std_selectICsByCluster(STUDY, ALLEEG, EEG, ...
						num2str(clustInclude), num2str(clustExclude), savePath, 1);

STUDY = pop_savestudy(STUDY, EEG, 'savemode', 'resave');
eeglab redraw