%% script for exporting peak

base_dir = '';
output_folder = '';
chan_labels = {'FCz'};
time_range = [450 650];  % the time range includes the peaks
component_label = 'N200';
direction = 'n';
n_sample = 2;

subj_exlucded = {};

%% Code begins

output_dir = fullfile(base_dir, output_folder);
mkdir_p(output_dir);

subj = to_col_vector(STUDY.subject);
subj_used = find(~ismember(subj, subj_excluded));

[STUDY, erp_data, erp_times] = ...
    std_erpplot(STUDY, ALLEEG, ...
                'channels', chan_labels, ...
                'subject', subj_used, ...
                'noplot', 'on', ...
                'averagechan', 'on');

var1 = to_row_vector(STUDY.design(1).variable(1).value);

[group_subjs, group_tags] = pick_study_group(STUDY);

for i = 1:length(group_subjs)  % loop through the group

    peaks_val = zeros(length(group_subjs{i}), length(var1));
    peaks_lat = peaks_val;
    
    for j = 1:length(var1)
        erp_this = erp_data{j, i};
        [peaks_val(:,j), peaks_lat(:,j)] = pick_peaks(erp_this, erp_times, time_range, ...
                                                      direction, n_sample);
    end 
    % prepare to write
    subj_this_grp = group_subjs{i};
    hdr = [{'subj'},var1];
    peaks_val_to_write = [hdr; [subj_this_grp, num2cellstr(peaks_val)]];
    peaks_lat_to_write = [hdr; [subj_this_grp, num2cellstr(peaks_lat)]];
    
    fname_peaks_val = sprintf('group-peaks-val-%s_%s_%s_t%i-%i.csv', ...
                              group_tags{i},...
                              component_labels,...
                              str_join(chan_labels, '-'),...
                              time_range(1),...
                              time_range(2));
    fname_peaks_lat = sprintf('group-peaks-lat-%s_%s_%s_t%i-%i.csv', ...
                              group_tags{i},...
                              component_labels,...
                              str_join(chan_labels, '-'),...
                              time_range(1),...
                              time_range(2));

    % write
    cell2csv(fullfile(output_dir, fname_peaks_val), 'peaks_val_to_write', ',');
    cell2csv(fullfile(output_dir, fname_peaks_val), 'peaks_lat_to_write', ',');
end
