function EEG = preproc_ica(EEG, g)

EEG = pop_resample(EEG, g.srate);
EEG = eeg_checkset(EEG);

EEG = filtering(EEG, g.high_hz, g.low_hz);
EEG = add_chanloc(EEG, g.brain_template, g.online_ref, g.append_online_ref);

% set eog
EEG = set_channel_types(EEG, g.veo, 'veo');
EEG = set_channel_types(EEG, g.heo, 'heo');

EEG = set_ref(EEG, g.offline_ref);

EEG.bk.rej.nonbrain_chans = g.nonbrain_chans;
EEG = rej_chan_by_label(EEG, g.nonbrain_chans);

bad_chans = rej_chan_by_bad(EEG, g.flatline, g.mincorr, g.linenoisy);
EEG.bk.rej.bad_chans = bad_chans;
EEG = set_channel_types(EEG, bad_chans, 'bad');

if is_avgref(g.offline_ref)
    fprintf('\n>>> average re-referencing <<<\n');
    EEG = set_ref_avg(EEG);
end

labels_ = {EEG.chanlocs.labels};
eeg_index = ~ismember({EEG.chanlocs.type}, {'veo', 'heo', 'bad'});
EEG = set_channel_types(EEG, labels_(eeg_index), 'eeg');

% epoching
EEG = pop_epoch(EEG, g.epoch_events, g.epoch_timerange);
EEG = eeg_checkset(EEG);

% zero mean
EEG = pop_rmbase(EEG, []);

[epoch_index, noisy_chans] = rej_detect_epoch(EEG, g.rejepoch);
EEG.bk.rej.epoch_index = epoch_index;
EEG.bk.rej.noisy_chans = noisy_chans;

% EEG = rej_chan_by_label(EEG, noisy_chans);
EEG = set_channel_types(EEG, noisy_chans, 'bad');

EEG = pop_rejepoch(EEG, epoch_index, 0);

if ~isempty(g.wrong_events)
    wrong_index = rej_epoch_by_response(EEG, g.wrong_events);
    EEG = pop_rejepoch(EEG, wrong_index, 0);
end

if ~isempty(g.resp_events) || ~isempty(g.resp_timewin)
    rt_rej_index = rej_epoch_by_rt(EEG, g.resp_events, g.resp_timewin);
    EEG = pop_rejepoch(EEG, rt_rej_index, 0);
end

% Run ICA
EEG = run_ica(EEG, is_avgref(g.offline_ref), {'eeg'});
EEG.bk.ica.icawinv = EEG.icawinv;
EEG.bk.ica.icasphere = EEG.icasphere;
EEG.bk.ica.icaweights = EEG.icaweights;
EEG.bk.ica.icachansind = EEG.icachansind;

EEG = rej_comp_by_EOG(EEG, g.veo, g.heo);
EEG.bk.rej.gcompreject = EEG.reject.gcompreject;
