output_dir = 'E:\gambling-ERP\lqs\output_erp';
chan_labels = {'Fz'};
time_range = [150, 300];
direction = 'n'; % or 'p';
n_sample = 4;
prefix = 'FRN';
output_type = 'peak'; % 'average' or 'peak'
lowpass_filter = 30;

% computing
if ~exist(output_dir, 'dir');
    mkdir(output_dir);
end
[STUDY, erp_data, erp_times] = ...
    compute_erp(STUDY, ALLEEG, ...
                chan_labels, ...
                lowpass_filter);
cfg.output_dir = output_dir;
cfg.range = pick_time(erp_times, time_range);
cfg.direction = direction;
cfg.n_sample = n_sample;
cfg.prefix = prefix;
cfg.output_type = output_type;
export_erp(erp_data, cfg);
