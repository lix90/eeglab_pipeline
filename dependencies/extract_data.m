function extract_data(eeg, marks)

if ischar(marks)
   marks = {marks}; 
end
origeeg = eeg;

for j = 1:numel(marks)
    
    fname = strcat(id{i}, '_', strrep(marks{j}, ' ', ''));
    out_filename = fullfile(output_dir, fname);
    % skip if already exist
    if exist(out_filename, 'file'); warning('files already exist'); continue; end
    EEG = pop_epoch(EEG, marks(j), [EEG.xmin*1000, EEG.xmax*1000]); % epoch into single condition
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1+j, ...
                                         'overwrite', 'off', 'gui', 'off', ...
                                         'savenew', out_filename);
    EEG = eeg_checkset( EEG );
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1+j, ...
                                         'retrieve', 1, 'study', 0); 
end
