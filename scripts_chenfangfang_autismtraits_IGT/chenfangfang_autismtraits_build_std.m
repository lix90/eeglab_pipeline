clear, close all, clc;

chenfangfang_autismtraits_init_param;

input_dir = fullfile(g.base_dir, g.split_output_folder);
output_dir = input_dir;
[input_fn, id] = get_fileinfo(input_dir, 'set');

% load sets
STUDY = []; ALLEEG = []; EEG = [];
EEG = pop_loadset('filename', input_fn, 'filepath', input_dir);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'study',0);

% build study commands
subj = strcat(get_fnpart(id, 2));
%cond = strcat(get_fnpart(id, 3));
grp = strcat(get_fnpart(id, 1));
studycommands = build_stdcmds(subj, [], grp);

% build study
build_std(STUDY, ALLEEG, EEG, g, studycommands, output_dir);
