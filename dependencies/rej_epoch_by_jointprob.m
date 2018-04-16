function EEG = rej_epoch_by_jointprob(EEG, local_thresh, global_thresh)

fprintf('***************************************\n');
fprintf('Detect bad epochs by joint probability.\n');
fprintf('***************************************\n');

if isempty(local_thresh)
    local_thresh = 8;
end

if isempty(global_thresh)
    global_thresh = 4;
end

ichan = find(pick_channel_types(EEG, {'eeg'}));
if isempty(ichan)
    ichan = 1:EEG.nbchan;
end
EEG = pop_jointprob(EEG, 1, ichan, ...
                    local_thresh, ...
                    global_thresh, ...
                    1, 0);
