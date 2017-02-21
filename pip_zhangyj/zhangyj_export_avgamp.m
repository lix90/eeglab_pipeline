%% script for exporting peak

base_dir = '';
output_folder = '';
chan_labels = {'FCz'};
time_range = [450 650];  % the time range includes the peaks
component_label = 'N200';

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

    amps = zeros(length(group_subjs{i}), length(var1)); 
    
    for j = 1:length(var1)
        erp_this = erp_data{j, i};
        amps(:,j) = pick_amplitude(erp_this, erp_times, time_range);
    end 
    % prepare to write
    subj_this_grp = group_subjs{i};
    hdr = [{'subj'},var1];
    amps_to_write = [hdr; [subj_this_grp, num2cellstr(amps)]];
    
    fname_amps = sprintf('amplitude_group-%s_%s_%s_t%i-%i.csv', ...
                         group_tags{i},...
                         component_label,...
                         str_join(chan_labels, '-'),...
                         time_range(1),...
                         time_range(2));
    
    % write
    cell2csv(fullfile(output_dir, fname_amps), amps_to_write, ','); 
end
