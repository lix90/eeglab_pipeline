function EEG = save_data(EEG, outfilename)

[fp, fn, ext] = fileparts(outfilename);
invalid_fp = isempty(fp) || ~exist(fp, 'dir');
if invalid_fp
   print_err('Invalid file path.');
end

EEG = pop_saveset(EEG, ...
                  'filename', outfilename,...
                  'savemode', 'twofiles',...
                  'version', '7.3');
