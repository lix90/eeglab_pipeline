%% script for exporting peak amplitude
chan_label = {'FCz'}; %channel labels of interest
time_range = [200 300]; % time range of erp component
output_dir = ''; % output directory
group_str = 'cn';
subj_exclude = {};

%% compute erp
%------------------------------------------------------
subj = STUDY.subject;
if ~isempty(subj_exclude)
    subj = subj(~ismember(subj, subj_exclude));
end
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
        erp_str = [erp_str, {num2str(erp_amp)}];
    end % within var end
        fprintf(fid, strcat(cellstrcat(erp_str, ','), '\n'));
end % subj loop end
    fclose(fid);


    % start prepare erp mean amplitude
    % erp_tmp = cellfun(@(x) {squeeze(mean(x(t(1):t(2), :)))}, erp_data);
    % erp_amp = transpose(cell2num(erp_tmp));
    % erp_str = cat(1, header, cat(2, subj, erp_amp, repmat('\n', [numel(subj), ...
    %                     1])));
    % cell2csv(fname_full, erp_str);
