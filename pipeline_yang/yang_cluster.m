% function iris_cluster

%%%%%% parameters
% dimensions
nspec = 5;
nerp = 5;
nscalp = 7;
% weights
wspec  = 2;
werp = 1;
wscalp = 3;
wdipoles = 10;
specrange = [1 30];
erptime = [0 500];
% cluster parameters
algorithm = 'kmeans';
clustNum = 30;
outLiers = 3;

%%%%%%% precluster
[STUDY ALLEEG] = std_preclust(STUDY, ALLEEG, 1, ...
	{'spec' 'npca' nspec 'norm' 1 'weight' wspec 'freqrange' specrange },...
	{'erp' 'npca' nerp 'norm' 1 'weight' werp 'timewindow' erptime },...
	{'scalp' 'npca' nscalp 'norm' 1 'weight' wscalp 'abso' 1},...
	{'dipoles' 'norm' 1 'weight' wdipoles});

%%%%%%% clustering
[STUDY] = pop_clust(STUDY, ALLEEG, ...
	'algorithm', algorithm, ...
	'clus_num',  clustNum, ...
	'outliers',  outLiers);
STUDY = pop_savestudy(STUDY, EEG, 'savemode', 'resave');
eeglab redraw