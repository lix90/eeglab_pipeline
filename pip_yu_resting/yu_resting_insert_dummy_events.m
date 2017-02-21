%% script for inserting dummy events for preprocessing

% ------------------------------------------------------------------------------
% Initialize variables
% ------------------------------------------------------------------------------

clear, clc, close all
base_dir = '';
input_folder = '';
output_folder = '';
file_ext = 'cnt';
fname_sep_pos = 3;  % filename seperator position, used to generate ids
recr = 1;  % interval of the dummy events, such as 1 second
lmts = [0 1];  % latencies relative to the events to use as epoch boundaries
rmbs = NaN;  % do not remove baseline
extr = 'off';  % do not extract epochs

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
    output_fname = sprintf('%s_crtevnt.set', id{i});
    output_fname_full = fullfile(output_dir, output_fname);
    if exist(output_fname_full, 'file')
        warning('files alrealy exist!')
        continue
    end

    % import dataset
    [EEG, ALLEEG, CURRENTSET] = import_data(input_dir, input_fname{i});

    % conditionally insert events
    if any(strfind(input_fname{i}, 'open'))
        evnt = 'open';
    elseif
        evnt = 'close';
    end
    % insert dum my events
    EEG = eeg_regepochs(EEG, 'recurrence', recr, ...
                        'limits', lmts, ...
                        'rmbase', rmbs, ...
                        'eventtype', evnt, ...
                        'extractepochs', extr);
    EEG = eeg_checkset(EEG);

    % save datasets
    EEG = pop_saveset(EEG, 'filename', output_fname_full);
    EEG = []; ALLEEG = []; CURRENTSET = [];

end
