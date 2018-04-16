function [STUDY, erp_data, erp_times] = compute_erp(STUDY, ALLEEG, chan_labels, ...
                                                  lowpass, timerange)

if ~exist('chan_labels', 'var')
    error('You must input channel labels to export erp.');
end

if ~exist('lowpass', 'var')
    lowpass = [];
end

if ~exist('timerange', 'var')
   timerange = [];
end

if isempty(chan_labels) || strcmp(chan_labels, 'all')
    chan_labels = [STUDY.changrp.channels];
end

[STUDY, erp_data, erp_times] = ...
    std_erpplot(STUDY, ALLEEG, ...
                'channels', chan_labels, ...
                'filter', lowpass, ...
                'timerange', timerange, ...
                'noplot', 'on', ...
                'averagechan', 'on');


