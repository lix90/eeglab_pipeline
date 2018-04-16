clear, close all, clc;

liujianbo_init_param;

input_dir = fullfile(g.base_dir, g.ica_output_folder);
output_dir = input_dir;
[input_fn, id] = get_fileinfo(input_dir, 'set');

% load sets
STUDY = []; ALLEEG = []; EEG = [];
EEG = pop_loadset('filename', input_fn, 'filepath', input_dir);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'study',0);

% build study commands
subj = strcat(get_fnpart(id, 1));
%cond = strcat(get_fnpart(id, 2));
%grp = strcat(get_fnpart(id, 2));
studycommands = build_stdcmds(subj, [], []);

% build study
build_std(STUDY, ALLEEG, EEG, g, studycommands, output_dir);
