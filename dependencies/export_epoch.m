function export_epoch(EEG, cfg)

% reject bad components
EEG = pop_subcomp(EEG, [], 0);
EEG = eeg_checkset(EEG);

% 
chans_selected = ~pick_channel_index(EEG, {'veo', 'heo'});
chanlocs = EEG.chanlocs(chans_selected);
chanlabels = {chanlocs.labels};

% interpolate
EEG = pop_interp(EEG, chanlocs, 'spherical');
EEG = eeg_checkset(EEG);
    
% pick epoch
events = cfg.events;

for i = 1:numel(events)
    
    data = pick_epoch(EEG, events(i));

    % prepare data
    chan_labels = [{'pnts'}, chanlabels];
    data_cell = num2cellstr(data');
    data_pnts = transpose(num2cellstr(1:size(data_cell,1)));
    data_write = [chan_labels; [data_pnts, data_cell]];

    
end
