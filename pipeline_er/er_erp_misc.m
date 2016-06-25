base_dir = '~/Data/gender-role-emotion-regulation/';
in_dir = fullfile(base_dir, 'dipfit');
ica_dir = fullfile(base_dir, 'dipfit2');

% prepare datasets
tmp = dir(fullfile(in_dir, '*.set'));
fileName = natsort({tmp.name});
ID = natsort(unique(get_prefix(fileName, 1)));

tmp_ica = dir(fullfile(ica_dir, '*.set'));
ica_filename = natsort({tmp_ica.name});
ID_ica = natsort(unique(get_prefix(ica_filename, 1)));

for i = 1:numel(ID)
    
    EEG = pop_loadset('filename', fileName{i}, 'filepath', in_dir);
    
    EEG2 = pop_loadset('filename', ica_filename{i}, 'filepath', ica_dir);
    
    EEG.reject.gcompreject(1:30) = EEG2.reject.gcompreject(1:30);
    
    EEG = eeg_checkset(EEG);
    
    EEG = pop_saveset(EEG, 'savemode', 'resave');
    
    EEG = []; EEG2 = [];
    
end