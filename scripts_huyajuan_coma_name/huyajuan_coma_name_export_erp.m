% ROI
% {'F3', 'Fz', 'F4', 'FC3', 'FCz', 'FC4'}

cfg.output_dir = '~/data_processing/huyajuan_coma_name/export';
cfg.chan_labels = {'C3', 'Cz', 'C4'}; % or multiple channels
cfg.time_range = [100, 250];
cfg.prefix = 'MMN';
cfg.output_type = 'peak'; % 'average' or 'peak'
cfg.lowpass_filter = 30;
cfg.direction = 'n'; % or 'p'; % just for peak
cfg.n_sample = 2; % just for peak
cfg.subj_excluded = []; % {'xxx'} or [];

if ~exist(cfg.output_dir, 'dir');
    mkdir(cfg.output_dir);
end
STUDY = export_erp(STUDY, ALLEEG, cfg);