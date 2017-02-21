%% script for creating study

% ------------------------------------------------------------------------------
% Initialize variables
% ------------------------------------------------------------------------------

base_dir = '';
study_folder = '';
file_ext = 'set';
fname_sep_pos = 1;
n_var = 2;  % number of variables
name_study = 'odd_ball_0.1hz_250hz.study';  % TODO: complete the study name
name_task = '';
note_study = '';

% ------------------------------------------------------------------------------
% Code starts
% ------------------------------------------------------------------------------

study_dir = fullfile(base_dir, study_folder);
[input_fname, id] = get_fileino(study_dir, file_ext, fname_sep_pos);
grp = cellfun(@(x) x(1:2), input_fname, 'uniformoutput', 'true');

% Load sets
ALLEEG = []; EEG = []; STUDY = [];
EEG = pop_loadset('filename', input_fname, 'filepath', study_dir);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'study',0);

% Create studycommands cell arrays
n_file = numel(input_fname)
studycommands = cell(size(input_fname));

for i = 1:n_file
    studycommands{i} = {'index', i, ...
                        'subject', id{i}, ...
                        'group', grp{i}};
end

[STUDY ALLEEG] = std_editset( STUDY, ALLEEG, ...
                              'name', name_study, ...
                              'task', name_task, ...
                              'notes', note_study, ...
                              'commands', studycommands, ...
                              'updatedat', 'on');

% STUDY = std_makedesign(STUDY, ALLEEG, 1, ...
% 					   'variable1', 'condition', 'pairing1', 'on', ...
% 					   'variable2', 'group', 'pairing2', 'on', ...
%                        'values1', V1, 'values2', V2, ...
%                        'filepath', outputDir);

STUDY = pop_savestudy(STUDY, EEG, 'filename', name_study, 'filepath', ...
                      study_dir);
