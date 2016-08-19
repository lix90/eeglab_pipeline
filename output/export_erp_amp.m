%% script for exporting peak amplitude

%% parameters
chan_label = {'FCz'}; %channel labels of interest
time_range = [200 300]; % time range of erp component
output_dir = ''; % output directory
g1 = {}; % marks of group one
g2 = {}; % marks of group two

%% compute erp
[STUDY, erpData, erpTimes] = std_erpplot(STUDY, ALLEEG, ...
                                         'channels', chanLabels, ...
                                         'noplot', 'on', ...
                                         'averagechan', 'on');
subj = STUDY.subject;
var1 = STUDY.design(1).variable(1).value;
var2 = STUDY.design(1).variable(2).value;
pairing1 = STUDY.design(1).variable(1).pairing;
pairing2 = STUDY.design(1).variable(2).pairing;

% time index
t = dsearchn(erpTimes', timeRange');
t1 = t(1); t2 = t(2);
