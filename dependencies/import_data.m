function [EEG, varargout] = import_data(input_dir, fname)
% wrapper function for import eeg data in eeglab easily
% set, eeg/vhdr, cnt, raw (egi binary data)
% Author: lix <alexiangli@outlook.com>
% TODO: one argout


% [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
ALLEEG = []; EEG = []; CURRENTSET = [];
[~,~,file_ext] = fileparts(fname);

% load dataset
switch file_ext
  case '.set'
    EEG = pop_loadset('filename', fname, 'filepath', input_dir);
  case '.eeg'
    if exist('pop_fileio')~=2
        disp('Warning: please install fileio plugin');
        return;
    end
    EEG = pop_fileio(fullfile(input_dir, fname));
  case '.cnt'
    try
        EEG = pop_loadcnt(fullfile(input_dir, fname), 'keystroke', 'on');
    catch
        disp('Warning: There is no keystroke in the raw data.');
        EEG = pop_loadcnt(fullfile(input_dir, fname));
    end
  case '.raw'
    disp('pop_readegi() automatically reads chanlocs.');
    EEG = pop_readegi(fullfile(input_dir, fname), [], [], 'auto');
  otherwise
    disp('file extension is not supported');
    return;
end
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0, ...
                                     'setname', fname(1:end-3), ...
                                     'gui','off'); 
EEG = eeg_checkset(EEG);

if nargout == 3
    varargout{1} = ALLEEG;
    varargout{2} = CURRENTSET; 
end
