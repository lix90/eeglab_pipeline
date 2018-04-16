% ROI
% {'F3', 'Fz', 'F4', 'FC3', 'FCz', 'FC4'}

cfg.output_dir = '~/data_processing/weigexin_bipolar_psychiatry_empathy/export';
cfg.chan_labels = {'CP3', 'CPz', 'CP4','P3', 'Pz', 'P4'}; % or multiple channels
cfg.time_range = [400, 600];
cfg.prefix = 'P3';
cfg.output_type = 'average'; % 'average' or 'peak'
cfg.lowpass_filter = 30;
cfg.direction = 'p'; % or 'p'; % just for peak
cfg.n_sample = 2; % just for peak
cfg.subj_excluded = []; % {'xxx'} or [];

if ~exist(cfg.output_dir, 'dir');
    mkdir(cfg.output_dir);
end
STUDY = export_erp(STUDY, ALLEEG, cfg);