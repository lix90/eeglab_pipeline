% std_selectICsByCluster

baseDir = '~/Data/yang_select';
savePath = fullfile(baseDir, 'spherical_back');
if ~exist(savePath, 'dir'); mkdir(savePath); end

clustInclude = [3:17, 21:32];

nClust = numel(STUDY.cluster.child);
idxClust = 2:(nClust+1);
clustExclude = setdiff(idxClust, clustInclude);

std_selectICsByCluster(STUDY, ALLEEG, EEG, ...
						num2str(clustInclude), num2str(clustExclude), savePath, 1);

STUDY = pop_savestudy(STUDY, EEG, 'savemode', 'resave');
eeglab redraw