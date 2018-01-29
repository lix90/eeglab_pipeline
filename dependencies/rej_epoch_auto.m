function [EEG, rej_epoch_index, rej_chan_by_epoch] = ...
        rej_epoch_auto(EEG, thresh_param, trends_param, ...
                       spectra_param, joint_param, kurt_param, ...
                       thresh_chan, reject)

info.orig_ntrial = EEG.trials;
info.orig_chanlocs = EEG.chanlocs;

% identify epoch
[index_rej, bad_chans] = ...
    rej_detect_epoch(EEG, thresh_param, trends_param, spectra_param, ...
                     joint_param, kurt_param, thresh_chan);

if reject
    EEG = rej_chan_by_label(EEG, badchans);
    EEG = pop_rejepoch(EEG, index_rej ,0);
end

info.rej_epoch_auto = index_rej;
labels = {info.orig_chanlocs.labels};
info.rej_chan_by_epoch = setdiff(labels, {EEG.chanlocs.labels});

