function EEG = importEEG(inputDir, filename)

% load dataset
fileExtention = filename{i}(end-2:end);
switch fileExtention
  case 'set'
    EEG = pop_loadset('filename', filename{i}, 'filepath', inputDir);
  case 'eeg'
    EEG = pop_fileio(fullfile(inputDir, filename{i}));
  otherwise
    disp('file extension does not match');
    return
end
EEG = eeg_checkset(EEG);

