function [EEG, info] = rej_epoch_auto(EEG, thresh_param, trends_param, ...
                                      spectra_param, joint_param, kurt_param, ...
                                      thresh_chan, reject)

info.orig_ntrial = EEG.trials;
info.orig_chanlocs = EEG.chanlocs;

% identify epoch
EEG = rej_detect_epoch(EEG, thresh_param, trends_param, spectra_param, ...
                       joint_param, kurt_param, thresh_chan);

if reject
    indexRej = EEG.reject.rejglobal;
    EEG = pop_rejepoch(EEG, indexRej ,0);
end

info.rej_epoch_auto = indexRej;
labels = {info.orig_chanlocs.labels};
info.rej_chan_by_epoch = setdiff(labels, {EEG.chanlocs.labels});

