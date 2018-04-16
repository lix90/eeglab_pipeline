function EEG = preproc_postica(EEG, g, bk)

if isfield(g, {'linenoise_freq'})
    if ~isfield(g, {'linenoise_bandwidth'})
        g.linenoise_bandwidth = [];
    end
    EEG = clean_linenoise(EEG, g.linenoise_freq, g.linenoise_bandwidth);
end

% rename events
if isfield(g, {'event_froms', 'event_tos'})
    disp('>>>>>>>>>>>>> renaming events <<<<<<<<<<<<<<<')
    EEG = rename_events(EEG, g.event_froms, g.event_tos);
end

% change latency
if isfield(g, {'change_latency_latency', 'change_latency_events'})
    disp('>>>>>>>>>>>>> changing latency <<<<<<<<<<<<<<<')
    EEG = change_event_latency(EEG, g.change_latency_events, g.change_latency_latency);
end

EEG = pop_resample(EEG, g.srate);
EEG = eeg_checkset(EEG);

EEG = filtering(EEG, g.high_hz, g.low_hz);

if isfield(g, ...
           {'brain_template', 'online_ref', 'append_online_ref'}) ...
        || ~isempty(g.brain_template);
EEG = add_chanloc(EEG, g.brain_template, g.online_ref, g.append_online_ref);
end

% set eog
if g.rej_eo
    EEG = set_channel_types(EEG, g.veo, 'veo');
    EEG = set_channel_types(EEG, g.heo, 'heo');
end

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

if g.ica_on_epoched_data
    EEG = pop_rejepoch(EEG, bk.rej.epoch_index, 0);
else
    [epoch_index, ~] = rej_detect_epoch(EEG, g.rejepoch);
    EEG = pop_rejepoch(EEG, epoch_index, 0);
end

if ~isempty(g.wrong_events)
    wrong_index = rej_epoch_by_response(EEG, g.wrong_events);
    EEG = pop_rejepoch(EEG, wrong_index, 0);
end

if ~isempty(g.resp_events) || ~isempty(g.resp_timewin)
    rt_rej_index = rej_epoch_by_rt(EEG, g.resp_events, g.resp_timewin);
    EEG = pop_rejepoch(EEG, rt_rej_index, 0);
end

EEG = pop_rmbase(EEG, []);

EEG.icawinv = bk.ica.icawinv;
EEG.icasphere = bk.ica.icasphere;
EEG.icaweights = bk.ica.icaweights;
EEG.icachansind = bk.ica.icachansind;
EEG = eeg_checkset(EEG);

EEG.etc.eeg_chanlocs = EEG.chanlocs(~pick_channel_types(EEG, {'veo', 'heo'}));
labels = {EEG.chanlocs.labels};
EEG = rej_chan_by_label(EEG, labels(~pick_channel_types(EEG, {'eeg'})));

EEG.reject.gcompreject = bk.rej.gcompreject;
if g.rej_components
    EEG = pop_subcomp(EEG, []);
end
