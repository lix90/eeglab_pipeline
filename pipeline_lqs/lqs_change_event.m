%% eeglab pipeline for lqs: change events
clear, clc, close
base_dir = '~/Data/lqs_gambling/';
in_dir = fullfile(base_dir, 'uncon');
ou_dir = fullfile(base_dir, 'change_event');
if ~exist(ou_dir, 'dir'); mkdir(ou_dir); end
pre = '22';

%%
event_from = {'S 11', 'S 22', 'S 33', 'S 44'};
if strcmp(pre, '11') || strcmp(pre, '21')
    event_to = {'yes_neg_mall', 'yes_neg_big', ...
                'yes_pos_small', 'yes_pos_big'}; % YES
elseif strcmp(pre, '12') || strcmp(pre, '22')
    event_to = {'no_neg_small', 'no_neg_big', ...
                'no_pos_small', 'no_pos_big'}; % NO
end
if strcmp(pre, '11') || strcmp(pre, '12')
    group = 'cn';
elseif strcmp(pre, '21') || strcmp(pre, '22')
    group = 'uc';
end
tmp_name = dir(fullfile(in_dir, strcat(pre, '-*.eeg')));
filename = {tmp_name.name};
[~, id] = strtok(filename, '-');
[id_subj, block] = strtok(id, '-');
[block, ~] = strtok(block, '.');

eeglab_opt;
for i = 1:numel(filename)
    name = sprintf('%s_subj%s_%s_block%s_change.set', ...
                   group, id_subj{i}, pre, block{i}(end));
    ou_name = fullfile(ou_dir, name);
    % if file exists
    if exist(ou_name, 'file')
        warning('files already exist');
        continue
    end
    % load rawdata (for eeg extension)
    EEG = pop_fileio(fullfile(in_dir, filename{i}));
    EEG = eeg_checkset(EEG);
    % change events
    EEG = lix_change_event(EEG, event_from, event_to);
    % save dataset
    EEG.setname = strcat('lqs_', filename, '_change_event');
    EEG = pop_saveset(EEG, 'filename', ou_name);
    EEG = [];
end
disp('DONE!');