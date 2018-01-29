function EEG = rej_chans(EEG, rej_chan_type)
% type: nonbrain or bad
% g.nonbrain_chans
% g.offline_ref
% g.flatline
% g.mincorr
% g.linenoisy

switch rej_chan_type
  case 'nonbrain'
   % remove channels
    if ~is_avgref(g.offline_ref)
        chans_rm = setdiff(g.nonbrain_chans, g.offline_ref);
    else
        chans_rm = rm_chans;
    end
    EEG = pop_select(EEG, 'nochannel', chans_rm);
  case 'bad'
    % reject bad channels
    % badChannels = eeg_detect_bad_channels(EEG);
    EEG = clean_rawdata(EEG, g.flatline, 'off', ...
                    g.mincorr, g.linenoisy, 'off', 'off');
    if ~isfield(EEG.etc, 'clean_channel_mask')
        EEG.etc.clean_channel_mask = ones(1, EEG.nbchan);
    end
    % labels = {EEG.chanlocs.labels};
    % badchans = labels(badChannels);
    % EEG = pop_select(EEG, 'nochannel', badChannels);
end
