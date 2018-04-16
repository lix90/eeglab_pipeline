%% get peak value and latency of Feedback related negativity;
output_dir = 'E:\gambling-ERP\lqs\output_erp';
chan_label = {'Fz'};
time_range = [160, 325];
lowpass_filter = 30;
prefix_str = '';
suffix_str = '';

FILT = 10;

[design_type, type_idx] = pick_design_type(STUDY);

[STUDY, erp_data, erp_times] = compute_erp(STUDY, ALLEEG, ...
                                           chan_labels, ...
                                           lowpass_filter);


t = pick_time(erp_times, time_range);
samples = t(1):t(2);
erp_roi = cellfun(@(x){x(t(1):t(2), :)}, erp_data);

frn = zeros(nSubj, nVar);
frn_lat = zeros(nSubj, nVar);
for i_v = 1:nVar
    for i_s = 1:nSubj
        v = erp_roi{i_v}(:, i_s);
        % find local maxing
        [lmaxv, imax] = lmax(v, FILT);
        [lminv, imin] = lmin(v, FILT);
        % check the number of peaks
        if isempty(union(lmaxv, imax))
            lmaxv = max(v);
        else
            lmaxv = mean(lmaxv);
        end
        if isempty(union(lminv, imin))
            frn_i = 0;
            frn_lat_i = erp_times(t2);
        else
            frn_i = lmaxv - mean(lminv);
            frn_lat_i = mean(erp_times(samples(imin)));
        end
        frn(i_s, i_v) = frn_i;
        frn_lat(i_s, i_v) = frn_lat_i;
    end
end

%%

% two way within
var_str = strcat(prefix, '_', cellstr_join(var1, var2, '_'));
% one way within
var_str = var1

header = cat(2, {'subject'}, strcat('peak_', var), strcat('latency_', var));
if size(subj, 2)~=1; subj = subj'; end
frn_tmp = cat(2, frn, frn_lat);
frn_tmp = arrayfun(@(x) {num2str(x)}, frn_tmp);
data_frn = cat(1, header, cat(2, subj, frn_tmp));

time_str = strcat('t', strrep(num2str(time_range), '  ', '-'));
chan_str = cellstrcat(chan_label, '-');
fname = strcat(group_str, '_peaklatency_', chan_str, '_', time_str, '.csv');
fname_full = fullfile(output_dir, fname);
cell2csv(fname_full, data_frn, ',');
