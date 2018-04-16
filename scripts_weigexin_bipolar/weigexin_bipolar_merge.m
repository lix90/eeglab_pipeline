clear, close all, clc;

weigexin_bipolar_init_param;

input_dir = fullfile(g.base_dir, g.raw_folder);
output_dir = fullfile(g.base_dir, 'merged');
[input_fn, id] = get_fileinfo(input_dir, g.file_ext);

if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

id = unique(strcat(get_fnpart(id, 1), '_', get_fnpart(id, 2)));
output_fn = fullfile(output_dir, strcat(id, '_merge.set'));

%%
for i = 1:numel(id)

print_info(id, i);
if exist(output_fn{i}, 'file'); warning('Files exist!'); continue; end;

set_ind = regexp(input_fn, strcat('^', id{i}, '_[a-z]+.set$'));
set_ind = ~(cellfun(@isempty, set_ind));
set_now = input_fn(set_ind);

 EEG = merge_data(input_dir, set_now);
 pop_saveset(EEG, 'filename', output_fn{i});

end
