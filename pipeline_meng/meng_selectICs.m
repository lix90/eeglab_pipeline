% std_selectICsByCluster

baseDir = 'F:\meng';
savePath = fullfile(baseDir, 'backproj');
if ~exist(savePath, 'dir'); mkdir(savePath); end

clustInclude = [3, 6, 7, 9, 10, 11, 13, 14, 15, 20, 21, 22, 24, 25, 26, 27, 28, 29, 31, 32, 33, 34, 35, 36, 37, 38, 39, 41, 42, 46];

nClust = numel(STUDY.cluster.child);
idxClust = 2:(nClust+1);
clustExclude = setdiff(idxClust, clustInclude);

std_selectICsByCluster(STUDY, ALLEEG, EEG, ...
						num2str(clustInclude), num2str(clustExclude), savePath, 1);

STUDY = pop_savestudy(STUDY, EEG, 'savemode', 'resave');