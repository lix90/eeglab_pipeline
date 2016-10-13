function [EEG, ALLEEG, CURRENTSET] = import_data(inputDir, filename)

% wrapper function for import eeg data in eeglab easily
% set, eeg, cnt
% written by lix 
% if run into problems, please contact its.lix@outlook.com


% [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
ALLEEG = []; EEG = []; CURRENTSET = [];
fileExtension = lower(filename(end-2:end));
% load dataset
switch fileExtension
  case 'set'
    EEG = pop_loadset('filename', filename, 'filepath', inputDir);
  case 'eeg'
    EEG = pop_fileio(fullfile(inputDir, filename));
  case 'cnt'
    EEG = pop_loadcnt(fullfile(inputDir, filename), 'keystroke', 'on');
  otherwise
    disp('file extension is not supported');
    return
end
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0, ...
                                     'setname', filename(1:end-3), ...
                                     'gui','off'); 
EEG = eeg_checkset(EEG);

