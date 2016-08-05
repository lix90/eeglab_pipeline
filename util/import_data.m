function [EEG, ALLEEG, CURRENTSET] = importEEG(inputDir, filename)

% wrapper function for import eeg data in eeglab easily
% written by lix 
% if run into problems, please contact its.lix@outlook.com


[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
fileExtension = filename(end-2:end);
% load dataset
switch fileExtension
  case 'set'
    EEG = pop_loadset('filename', filename, 'filepath', inputDir);
  case 'eeg'
    EEG = pop_fileio(fullfile(inputDir, filename));
  case 'cnt'
    EEG = pop_loadcnt(fullfile(inputDir, filename), 'keystroke', 'on');
  otherwise
    disp('file extension does not match');
    return
end
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0, ...
                                     'setname', filename(1:end-3), ...
                                     'gui','off'); 
EEG = eeg_checkset(EEG);

