function EEG = merge_data(inputdir, inputfilename)

% load set
ALLEEG = []; EEG = []; CURRENTSET = 0;
for j = 1:length(inputfilename)
    % switch file_ext
    %     case 'eeg'
    %         EEG = pop_fileio(fullfile(inputdir, inputfilename{j}));
    %     case 'set'
    %         EEG = pop_loadset('filename', inputfilename{j}, 'filepath', inputdir);
    % end
    EEG = import_data(inputdir, inputfilename{j});
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, j);
    EEG = eeg_checkset(EEG);
end

% merge set
N = length(ALLEEG);
if N > 1
    EEG = pop_mergeset(ALLEEG, 1:N, 0);
    EEG = eeg_checkset(EEG);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,...
                                         'overwrite','on');
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = eeg_checkset(EEG);
end
