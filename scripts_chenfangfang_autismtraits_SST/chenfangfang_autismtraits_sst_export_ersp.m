cfg.output_dir = '~/data_processing/chenfangfang_autismtraits_sst/export';
cfg.chan_labels = {'O2'}; % or multiple channels
cfg.time_range = [600, 800];
cfg.freq_range = [4 7];
cfg.prefix = 'theta';

if ~exist(cfg.output_dir, 'dir');
    mkdir(cfg.output_dir);
end
STUDY = export_ersp(STUDY, ALLEEG, cfg);