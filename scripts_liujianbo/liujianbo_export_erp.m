cfg.chan_labels = {'O2'}; % or multiple channels
cfg.time_range = [350, 450];
cfg.prefix = 'P3';
cfg.output_type = 'average'; % 'average' or 'peak'
cfg.lowpass_filter = 30;
cfg.direction = 'p'; % or 'p'; % just for peak
cfg.n_sample = 2; % just for peak

liujianbo_init_param;
cfg.output_dir = fullfile(g.base_dir, g.output_folder);

if ~exist(cfg.output_dir, 'dir');
    mkdir(cfg.output_dir);
end

STUDY = export_erp(STUDY, ALLEEG, cfg);
