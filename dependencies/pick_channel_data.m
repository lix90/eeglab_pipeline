function outdata = pick_channel_data(EEG, labels)

if ischar(labels)
    labels = {labels};
end

nd = ndims(EEG.data);
idx = pick_channels(EEG, labels);

switch nd
  case 2
    outdata = EEG.data(idx, :);
  case 3
    outdata = EEG.data(idx, :, :);
end

if length(labels)==1
    outdata = squeeze(outdata);
end
