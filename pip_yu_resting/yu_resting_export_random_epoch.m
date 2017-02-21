%% script for applying ica

% Output data stucture:
% pnts Ch1 Ch2 Ch3 ... Chn
% 1    x
% 2    x
% 3    x
% 4    x
% ...  ...
% n    x

% ------------------------------------------------------------------------------
% Initialize variables
% ------------------------------------------------------------------------------

clear, clc, close all
base_dir = '';
input_folder = 'epoch_3s';
output_folder = 'output_3s';
file_ext = 'set';
fname_sep_pos = 2;  % filename seperator position, used to generate ids
exp_type = 'ce';  % experiment type, close eye or open eye

% ------------------------------------------------------------------------------
% Code begins
% ------------------------------------------------------------------------------

% Directory
input_dir = fullfile(base_dir, input_folder);
output_dir = fullfile(base_dir, output_folder);
mkdir_p(output_dir);  % create directory if not exist

% Get filenames
[input_fname, id] = get_fileinfo(input_dir, file_ext, fname_sep_pos);

for i = 1:numel(input_fname)

    fprintf('\n\n***** dataset %i/%i: %s *****\n\n', i, numel(id), id{i});
    output_fname = sprintf('%s_%s.txt', exp_type, id{i});
    output_fname_full = fullfile(output_dir, output_fname);
    if exist(output_fname_full, 'file')
        warning('files alrealy exist!')
        continue
    end

    % import dataset
    [EEG, ~, ~] = import_data(input_dir, input_fname{i}); 

    % reject bad components
    EEG = pop_subcomp(EEG, [], 0);
    EEG = eeg_checkset(EEG);

    % interpolate
    EEG = pop_interp(EEG, EEG.info.orig_chanlocs, 'spherical');
    EEG = eeg_checkset(EEG);
    
    % pick epoch randomly
    data = pick_epoch(EEG);
    
    % prepare data
    chan_labels = [{'pnts'}, {EEG.chanlocs.labels}];
    data_cell = num2cellstr(data');
    data_pnts = transpose(num2cellstr(1:size(data_cell,1)));
    data_write = [chan_labels; [data_pnts, data_cell]];
    
    % write to csv file
    cell2csv(output_fname_full, data_write, ',');

end
