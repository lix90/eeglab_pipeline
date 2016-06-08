%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear, clc, close all

% set directory
baseDir = '~/Data/moodPain_final/';
inputDir = fullfile(baseDir, 'interp_rv15_2');
outputDir = fullfile(baseDir, 'single_rv15_2');
poolsize = 8;
Events = {'Pos_Pain', 'Pos_noPain', ...
          'Neg_noPain', 'Neg_Pain', ...
          'Neu_noPain', 'Neu_Pain' };
epochtime = [-1 2];
% prepare datasets
if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
tmp = dir(fullfile(inputDir, '*.set'));
fileName = natsort({tmp.name});
nFile = numel(fileName);
id = get_prefix(fileName, 1);
id = natsort(unique(id));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:nFile
    ALLEEG = []; EEG = []; CURRENTSET = 0;
    % load set
    fprintf('Loading (%i/%i %s)\n', i, length(fileName), fileName{i});
    EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset(EEG);
    EEG = pop_subcomp(EEG, [], 0);
    EEG = eeg_checkset(EEG);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off', 'overwrite', ...
                                         'on');
    %% csd
    % disp('laplacian');
    % laplac = eeg_laplac(EEG, 1);
    % laplac = reshape(laplac, [size(EEG.data)]);
    % EEG.data = laplac;
    % EEG = eeg_checkset(EEG);
    % [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off', 'overwrite', ...
    %                                      'on');
    
    for j = 1:numel(Events)
        name = strcat(id{i}, '_', Events{j});
        outName = fullfile(outputDir, name);
        % skip if already exist
        if exist(outName, 'file'); warning('files already exist'); continue; end
        EEG = pop_epoch(EEG, Events(j), epochtime); % epoch into single condition
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1+j, ...
                                             'overwrite', 'off', 'gui', 'off', ...
                                             'savenew', outName);        
        EEG = eeg_checkset( EEG );
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1+j, ...
                                             'retrieve', 1, 'study', 0); 
    end
    ALLEEG = []; EEG = []; CURRENTSET = 0;
end
