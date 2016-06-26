function EEG = importEEG(inputDir, filename)

fileExtension = filename(end-2:end);
% load dataset
switch fileExtension
  case 'set'
    EEG = pop_loadset('filename', filename, 'filepath', inputDir);
  case 'eeg'
    EEG = pop_fileio(fullfile(inputDir, filename));
  otherwise
    disp('file extension does not match');
    return
end
EEG = eeg_checkset(EEG);

