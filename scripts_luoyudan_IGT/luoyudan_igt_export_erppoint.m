cfg.output_dir = '~/data_processing/luoyudan_OCD_IGT/export_erppoint';
cfg.lowpass_filter = [];
cfg.prefix = '';
if ~exist(cfg.output_dir, 'dir');
    mkdir(cfg.output_dir);
end
STUDY = export_erppoint(STUDY, ALLEEG, cfg);

