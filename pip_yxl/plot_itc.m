chan_labels = {''};


% compute itc
[STUDY, itc_data, itc_times, itc_freqs] = ...
    std_itcplot(STUDY, ALLEEG, 'subbaseline', 'on');
chanlabels = [STUDY.changrp.channels];
idx_e = find(ismember(chanlabels, chan_labels));


