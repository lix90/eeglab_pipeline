function bads = rej_chan_by_bad(EEG, flatline, mincorr, linenoisy);

% reject bad channels
% badChannels = eeg_detect_bad_channels(EEG);
goods = {EEG.chanlocs.labels};
EEG = clean_rawdata(EEG, flatline, 'off', ...
                    mincorr, linenoisy, 'off', 'off');
if ~isfield(EEG.etc, 'clean_channel_mask')
    EEG.etc.clean_channel_mask = ones(1, EEG.nbchan);
end
% labels = {EEG.chanlocs.labels};
% badchans = labels(badChannels);
% EEG = pop_select(EEG, 'nochannel', badChannels);
bads = goods(~EEG.etc.clean_channel_mask);
