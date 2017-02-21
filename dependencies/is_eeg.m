function out = is_eeg(EEG)
% Identify EEG struct

fieldnames = {'nbchan', 'trials', 'pnts', 'srate', 'xmin', 'xmax', ...
              'times', 'data'};
out = isstruct(EEG) && all(isfield(EEG, fieldnames));
