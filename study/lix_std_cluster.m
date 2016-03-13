function lix_std_cluster(params)

nspec = params.cluster.npca.spec = 5;
nerp = params.cluster.npca.erp = 5;
nscalp = params.cluster.npca.scalp = 7;
% params.cluster.npca.dipoles = 3; % which is default setting
% params.cluster.npca.
wspec = params.cluster.weight.spec = 2;
werp = params.cluster.weight.erp = 1;
wscalp = params.cluster.weight.scalp = 3;
wdipoles = params.cluster.weight.dipoles = 10;
specrange = params.cluster.specfreqrange = [3 30];
erptime = params.cluster.erptimewindow = [0 500];

% precluster
[STUDY ALLEEG] = std_preclust(STUDY, ALLEEG, 1, ...
	{'spec' 'npca' nspec 'norm' 1 'weight' wspec 'freqrange' specrange },...
	{'erp' 'npca' nerp 'norm' 1 'weight' werp 'timewindow' erptime },...
	{'scalp' 'npca' nscalp 'norm' 1 'weight' wscalp 'abso' 1},...
	{'dipoles' 'norm' 1 'weight' wdipoles});
% cluster
[STUDY] = pop_clust(STUDY, ALLEEG, ...
	'algorithm','kmeans',...
	'clus_num',  10 ,...
	'outliers',  3 );
STUDY = pop_savestudy(STUDY, EEG, 'savemode', 'resave');