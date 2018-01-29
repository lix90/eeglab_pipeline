function EEG = rej_chan_by_label(EEG, labels)

% remove channels
% if ~is_avgref(g.offline_ref)
%     chans_rm = setdiff(g.nonbrain_chans, g.offline_ref);
% else
%     chans_rm = rm_chans;
% end
EEG = pop_select(EEG, 'nochannel', labels);
EEG = eeg_checkset(EEG);
