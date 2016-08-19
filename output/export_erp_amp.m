%% script for exporting peak amplitude
chan_label = {'FCz'}; %channel labels of interest
time_range = [200 300]; % time range of erp component
output_dir = ''; % output directory
group_str = 'cn';

%% compute erp
subj = STUDY.subject;
var = STUDY.design(1).variable(1).value;
[STUDY, erp_data, erp_times] = std_erpplot(STUDY, ALLEEG, ...
                                           'channels', chan_label, ...
                                           'noplot', 'on', ...
                                           'averagechan', 'on');
% time index
t = dsearchn(erp_times', time_range');
% prepare output name
time_str = strcat('t', strrep(num2str(time_range), '  ', '-'));
chan_str = cellstrcat(chan_label, '-');
fname = strcat(group_str, '_amplitude_', chan_str, '_', time_str, '.csv');
fname_full = fullfile(output_dir, fname);

header = strcat('subject,', cellstrcat(var, ','), '\n');
fid = fopen(fname_full, 'w');
fprintf(fid, header);

for i_s = 1:numel(subj)
    fprintf(fid, [subj{i_s}, ',']);
    erp_str = [];
    for i_v = 1:numel(var)
        erp_amp = mean(erp_data{i_v}(t(1):t(2), i_s));
        erp_str = [erp_str, cell(num2str(erp_amp))];
    end % within var end
        fprintf(fid, strcat(cellstrcat(erp_str, ','), '\n'));
end % subj loop end
    fclose(fid);
