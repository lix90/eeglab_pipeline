cfg.output_dir = '~/data_processing/luoyudan_OCD_IGT/export';
cfg.chan_labels = {'O2'}; % or multiple channels
cfg.time_range = [350, 450];
cfg.prefix = 'P3';
cfg.output_type = 'average'; % 'average' or 'peak'
cfg.lowpass_filter = 30;
cfg.direction = 'p'; % or 'p'; % just for peak
cfg.n_sample = 2; % just for peak

if ~exist(cfg.output_dir, 'dir');
    mkdir(cfg.output_dir);
end
STUDY = export_erp(STUDY, ALLEEG, cfg);