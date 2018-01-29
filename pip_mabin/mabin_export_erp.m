%% script for exporting erp
% 1. averaged amplitude of potentials
% 2. peak of potentials
% 3. peak latency of potentials

chan_label = {'FCz'};
time_range = [200, 300];
output_dir = '';
excluded_subj = [];

% erp_data: { nconds * ngroups } [ times * subjects ]
[STUDY, erp_data, erp_times] = ...
    std_erpplot(STUDY, ALLEEG, ...
                'channels', chan_label, ...
                'noplot', 'on', ...
                'averagechan', 'on');
subj = STUDY.subject;
var1 = STUDY.design(1).variable(1).value;
var2 = STUDY.design(1).variable(2).value;


