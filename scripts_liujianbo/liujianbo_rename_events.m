clear, close all, clc;

liujianbo_init_param;

g.event_type = 'stm+';

input_dir = fullfile(g.base_dir, g.raw_folder);
output_dir = fullfile(g.base_dir, g.rename_folder);
[input_fn, id] = get_fileinfo(input_dir, g.file_ext);
output_fn = fullfile(output_dir, strcat(id, '_rename.set'));
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

for i = 1:numel(id)
    
    fprintf('dataset %i/%i: %s\n', i, numel(id), id{i});
    if exist(output_fn{i}, 'file')
        warning('files alrealy exist!');
        continue;
    end
    EEG = import_data(input_dir, input_fn{i});
    typelist = readtxtdata(fullfile(g.base_dir, g.text_folder, ...
                                    strcat(id{i}, '.txt')),...
                           '%s', '\n', 1, 'num');
    typelist = num2cellstr(typelist);
    for t = 1:numel(g.event_froms)
       typelist(ismember(typelist, g.event_froms(t))) = g.event_tos(t);
    end
    
        % find index of stimuli events
        stim = find(ismember({EEG.event.type}, g.event_type));
        if numel(stim) ~= numel(typelist)
            fprintf('stim n: %i; typelist n: %i', numel(stim), numel(typelist));
           error('The number of stim and typelist is not the same.');
        end
        % change event name
        for j = 1:numel(stim)
           EEG.event(stim(j)).type = typelist{j};
        end
    
    parsaveset(EEG, output_fn{i});
    
end
