function eeg_to_set(input_dir, from, output_dir, to)

if ~iscellstr(from) && ~iscellstr(to)
from = {from};
to = {to};
end

for i = numel(from)
EEG = import_data(input_dir, from);
pop_saveset(EEG, 'filename', fullfile(output_dir, to));
end