function EEG = preproc_postica(EEG, g, bk)

EEG = pop_resample(EEG, g.srate);
EEG = eeg_checkset(EEG);

EEG = filtering(EEG, g.high_hz, g.low_hz);
EEG = add_chanloc(EEG, g.brain_template, g.online_ref, g.append_online_ref);

% set eog
EEG = set_channel_types(EEG, g.veo, 'veo');
EEG = set_channel_types(EEG, g.heo, 'heo');

EEG = set_ref(EEG, g.offline_ref);

EEG = rej_chan_by_label(EEG, g.nonbrain_chans);

EEG = set_channel_types(EEG, bk.rej.bad_chans, 'bad');
EEG = set_channel_types(EEG, bk.rej.noisy_chans, 'bad');

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
EEG = pop_rmbase(EEG, []);

EEG = pop_rejepoch(EEG, bk.rej.epoch_index, 0);

if ~isempty(g.wrong_events)
    wrong_index = rej_epoch_by_response(EEG, g.wrong_events);
    EEG = pop_rejepoch(EEG, wrong_index, 0);
end

if ~isempty(g.resp_events) || ~isempty(g.resp_timewin)
    rt_rej_index = rej_epoch_by_rt(EEG, g.resp_events, g.resp_timewin);
    EEG = pop_rejepoch(EEG, rt_rej_index, 0);
end


EEG.icawinv = bk.ica.icawinv;
EEG.icasphere = bk.ica.icasphere;
EEG.icaweights = bk.ica.icaweights;
EEG.icachansind = bk.ica.icachansind;
EEG = eeg_checkset(EEG);

labels = {EEG.chanlocs.labels};
EEG = rej_chan_by_label(EEG, labels(~pick_channel_types(EEG, {'eeg'})));

EEG.reject.gcompreject = bk.rej.gcompreject;
if g.rej_components
    EEG = pop_subcomp(EEG, []);
end
