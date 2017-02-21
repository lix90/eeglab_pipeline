%% script for applying ica

% ------------------------------------------------------------------------------
% Initialize variables
% ------------------------------------------------------------------------------

clear, clc, close all
base_dir = '';
input_folder = 'raw';
ica_folder = 'ica';
output_folder = 'epoch_3s';
file_ext = 'set';
fname_sep_pos = 2;  % filename seperator position, used to generate ids
exp_type = 'ce';  % experiment type, close eye or open eye

% channel locations
brain_template = 'Spherical';  % Spherical
online_ref = 'M1';
add_online_ref = true;
offline_ref = {'M1', 'M2'};

% filtering
sampling_rate = 250;
high_pass = 1;
low_pass = 40;

% epoching
epoch_event = 'ce';  % dummy events, such as CE (close eye) or OE (open eye)
epoch_time = [-0.5, 2.5];  % IMPORTANT: in order to rejecting boundaries

% thresholds for detecting bad epochs
thresh_param.low_thresh = -300;
thresh_param.up_thresh = 300;
trends_param.slope = 200;
trends_param.r2 = 0.3;
spectra_param.threshold = [-35, 35];
spectra_param.freqlimits = [20 40];
joint_param.single_chan = 8;
joint_param.all_chan = 4;
kurt_param.single_chan = 8;
kurt_param.all_chan = 4;
thresh_chan = 1;
reject = 1;

% ------------------------------------------------------------------------------
% Code begins
% ------------------------------------------------------------------------------

% Directory
input_dir = fullfile(base_dir, input_folder);
ica_dir = fullfile(base_dir, ica_folder);
output_dir = fullfile(base_dir, output_folder);
mkdir_p(output_dir);  % create directory if not exist

% Get filenames
[input_fname, id] = get_fileinfo(input_dir, file_ext, fname_sep_pos);
[input_fname_ica, ~] = get_fileinfo(ica_dir, file_ext, fname_sep_pos);

rm_chans = {'HEOL', 'HEOR', 'HEOG', 'HEO', ...
            'VEOD', 'VEO', 'VEOU', 'VEOG', ...
            'M1', 'M2', 'TP9', 'TP10', ...
            'CB1', 'CB2', 'E63', 'E64', ...
            'E23', 'E59'};

for i = 1:numel(input_fname)

    fprintf('\n\n***** dataset %i/%i: %s *****\n\n', i, numel(id), id{i});
    output_fname = sprintf('%s_%s_ica.set', exp_type, id{i});
    output_fname_full = fullfile(output_dir, output_fname);
    if exist(output_fname_full, 'file')
        warning('files alrealy exist!')
        continue
    end

    % import dataset
    [EEG, ALLEEG, CURRENTSET] = import_data(input_dir, input_fname{i});
    [icaEEG, ~, ~] = import_data(ica_dir, input_fname_ica{i});

    % high pass filtering
    EEG = pop_eegfiltnew(EEG, high_pass, 0);
    EEG = eeg_checkset(EEG);

    % low pass filtering
    if ~isempty(lowpass)
        EEG = pop_eegfiltnew(EEG, 0, low_pass);
        EEG = eeg_checkset(EEG);
    end

    % add channel locations
    EEG = add_chanloc(EEG, brain_template, online_ref, add_online_ref);

    % remove channels
    if ~isavg
        real_rm_chans = setdiff(rm_chans, offline_ref);
    else
        real_rm_chans = rm_chans;
    end

    EEG = pop_select(EEG, 'nochannel', real_rm_chans);
    EEG = eeg_checkset(EEG);

    % re-reference if necessary
    labels = {EEG.chanlocs.labels};
    if ~isavg
        real_off_ref = intersect(labels, off_ref);
        if strcmpi(char(real_off_ref), 'm2')
            indexM2 = find(ismember(labels, real_off_ref));
            EEG.data(indexM2, :) = EEG.data(indexM2, :)/2;
        end
        EEG = pop_reref(EEG, find(ismember(labels, real_off_ref)));
        EEG = eeg_checkset(EEG);
    else
        EEG = pop_reref(EEG, []);
        EEG = eeg_checkset(EEG);
    end

    orig_chanlocs = EEG.chanlocs;

    % reject bad channels 
    EEG = pop_select(EEG, 'nochannel', icaEEG.info.badchans);

    % re-reference if offRef is average
    if isavg
        EEG = pop_reref(EEG, []);
        EEG = eeg_checkset(EEG);
    end

    % epoching
    EEG = pop_epoch(EEG, natsort(epoch_event), epoch_time, 'epochinfo', 'yes');
    EEG = eeg_checkset(EEG);

    % baseline-zero
    EEG = pop_rmbase(EEG, []);

    % down-sampling
    EEG = pop_resample(EEG, sampling_rate);
    EEG = eeg_checkset(EEG);

    % reject epochs
    [EEG, EEG.info] = rej_epoch_auto(EEG, thresh_param, trends_param, spectra_param, ...
                                     joint_param, kurt_param, thresh_chan, reject);

    
    % apply ica & bad components into EEG
    EEG = apply_ica(EEG, icaEEG, true);    
    EEG.info.orig_chanlocs = orig_chanlocs;
    
    % save datasets
    EEG = pop_saveset(EEG, 'filename', output_fname_full);
    EEG = []; ALLEEG = []; CURRENTSET = [];

end
