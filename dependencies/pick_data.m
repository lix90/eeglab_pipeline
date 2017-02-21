function outdata = pick_data(EEG, labels, event_ids, time_range, is_average)
% Get data based on selected channel labels and event_ids and maybe with
% time range
% The input EEG data must be epoched.


if ~exist('time_range', 'var')
    time_range = [];  % [] means using the all time range
else
    idx_t = pick_time(EEG.times, time_range);
end

if ~exist('is_average', 'var')
    is_average = true;
end

if ischar(labels)
    labels = {labels};
end

if ischar(event_ids)
    event_ids = {event_ids};
end

if ndims(EEG.data)~=3
    disp(['Error:\n' ...
          'The input EEG data must be epoched.\n' ...
          'If you want pick data from non-epoched data with channel labels\n' ...
          'you should refer to the function `pick_channels`\n']);
    return;
end

idx_ch = pick_channel_index(EEG, labels);
idx_id = pick_event_index(EEG, event_ids);
if isempty(time_range)
    outdata = EEG.data(idx_ch, :, idx_id);
else
    if length(idx_t)==1
        outdata = EEG.data(idx_ch, idx_t, idx_id);
    elseif length(idx_t)==2
        outdata = EEG.data(idx_ch, idx_t(1):idx_t(2), idx_id);
        if is_average
            outdata = mean(outdata, 2);
        end
    end
end

if length(labels)==1 || length(event_ids)==1
    outdata = squeeze(outdata);
end
