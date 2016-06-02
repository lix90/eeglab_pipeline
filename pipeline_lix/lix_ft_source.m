file_path = '~/data/Mood-Pain-Empathy/single_rv15_2/';
file_name = 'zhoujiahua_Pos_noPain.set';
% load data
EEG = pop_loadset('filename', file_name, 'filepath', file_path);
ft_data = eeglab2fieldtrip(EEG, 'preprocessing', 'none');
% time windows of interest
cfg = [];
cfg.toilim = [-0.7 -0.2];
dataPre = ft_redefinetrial(cfg, ft_data);
cfg.toilim = [0.5 1];
dataPost = ft_redefinetrial(cfg, ft_data);
% calculate cross spectral density
cfg = [];
cfg.method = 'mtmfft';
cfg.output = 'powandcsd';
cfg.tapsmofrq = 2;
cfg.foilim = [10 10];
freqPre = ft_freqanalysis(cfg, dataPre);
cfg = [];
cfg.method = 'mtmfft';
cfg.output = 'powandcsd';
cfg.tapsmofrq = 2;
cfg.foilim = [10 10];
freqPost = ft_freqanalysis(cfg, dataPost);

%% prepare head model
vol_name = 'standard_bem.mat';
load(vol_name);

%% compute lead fields
cfg = [];
cfg.elec = freqPost.elec;
cfg.headmodel = vol;
cfg.reducerank = 2;
cfg.grid.resolution = 1; % use a 3-D grid with a 1 cm resolution
cfg.grid.unit = 'cm';
[grid] = ft_prepare_leadfield(cfg);

%% source analysis: without contrasting
cfg = [];
cfg.method = 'dics';
cfg.frequency = 10;
cfg.grid = grid;
cfg.headmodel = vol;
cfg.dics.projectnoise = 'yes';
cfg.dics.lambda = 0;
sourcePost_nocon = ft_sourceanalysis(cfg, freqPost);

%%
mri_name = 'standard_mri.mat';
load(mri_name);
cfg = [];
cfg.downsample = 2;
cfg.parameter = 'avg.pow';
sourcePostInt_nocon = ft_sourceinterpolate(cfg, sourcePost_nocon , mri);

%% plot interpolated data
cfg = [];
cfg.method = 'slice';
cfg.funparameter = 'avg.pow';
figure
ft_sourceplot(cfg,sourcePostInt_nocon);

%% neural acitivty index
sourceNAI = sourcePost_nocon;
sourceNAI.avg.pow = sourcePost_nocon.avg.pow./sourcePost_nocon.avg.noise;
cfg = [];
cfg.downsample = 2;
cfg.parameter = 'avg.pow';
sourceNAIInt = ft_sourceinterpolate(cfg, sourceNAI , mri);

%% plot
cfg = [];
cfg.method = 'slice';
cfg.funparameter = 'avg.pow';
cfg.maskparameter = cfg.funparameter;
cfg.funcolorlim = [1.0 1.2];
cfg.opacitylim = [1.0 1.2];
cfg.opacitymap = 'rampup';

ft_sourceplot(cfg, sourceNAIInt);

%% contrast
dataAll = ft_appenddata([], dataPre, dataPost);
cfg = [];
cfg.method = 'mtmfft';
cfg.output = 'powandcsd';
cfg.tapsmofrq = 2;
cfg.foilim = [10 10];
freqAll = ft_freqanalysis(cfg, dataAll);
