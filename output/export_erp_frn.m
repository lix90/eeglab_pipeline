%% get peak value and latency of Feedback related negativity;
output_dir = 'E:\gambling-ERP\lqs\output_erp';
chan_label = {'Fz'};
time_range = [160, 325];
group_str = 'cn';
subj_exclude = {};

lowpass = 30;
trange = [-200, 1000];
FILT = 10;

%% compute erp
subj = STUDY.subject;
if ~isempty(subj_exclude)
    subj = subj(~ismember(subj, subj_exclude));
end
var = STUDY.design(1).variable(1).value;
nVar = numel(var);
nSubj = numel(subj);

[STUDY, erp_data, erp_times] = std_erpplot(STUDY, ALLEEG, ...
                                           'channels', chan_label, ...
                                           'filter', lowpass, ...
                                           'timerange', trange, ...
                                           'noplot', 'on', ...
                                           'averagechan', 'on');

t1 = find(erp_times>=time_range(1), 1, 'first');
t2 = find(erp_times>=time_range(2), 1, 'first');
samples = t1:t2;
erp_roi = cellfun(@(x){x(t1:t2, :)}, erp_data);


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
