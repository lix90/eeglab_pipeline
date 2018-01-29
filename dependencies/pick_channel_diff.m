function labels = pick_channel_diff(chanlocs_old, chanlocs_new)

old_labels = {chanlocs_old.labels};
new_labels = {chanlocs_new.labels};
labels = setdiff(old_labels, new_labels);
