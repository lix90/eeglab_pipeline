clear, clc, close all
base_dir = '~/Data/mabin/';
input_tag = 'merge';
icamat_tag = 'pre';
output_tag = 'erp8s';
file_ext = 'set';
file_ext_ica = 'mat';

brain_template = 'Spherical';
on_ref = 'FCz';
append_on_ref = true;
off_ref = {'TP9', 'TP10'};

srate = 250;
hipass = [];
lowpass = 45;
marks = {'S 11', 'S 12', ...
         'S 21', 'S 22', ...
         'S 31', 'S 32'};
epoch_time = [-1.5, 8];

flatline = 5;
mincorr = 0.4;
linenoisy = [];

input_dir = fullfile(base_dir, input_tag);
output_dir = fullfile(base_dir, output_tag);
icamat_dir = fullfile(base_dir, icamat_tag);
if ~exist(output_dir, 'dir'); mkdir(output_dir); end

in_filename = get_filename(input_dir, file_ext);
id = get_id(in_filename);
in_filename_ica = strcat(id, '_', icamat_tag, '.mat');

rm_chans = {'HEOL', 'HEOR', 'HEOG', 'HEO', ...
            'VEOD', 'VEO', 'VEOU', 'VEOG', ...
            'M1', 'M2', 'TP9', 'TP10', ...
            'CB1', 'CB2'};

% set_matlabpool(2);

for i = 1:numel(id)

    EEG = []; ALLEEG = []; CURRENTSET = 0;
    print_info(id, i);
    out_filename = fullfile(output_dir, sprintf('%s_%s.set', id{i}, output_tag));
    if exist(out_filename, 'file')
        warning('files alrealy exist!')
        continue
    end
    
    ica = struct();
    if strcmp(off_ref, 'average')
        isavg = 1;
    else
        isavg = 0;
    end

    % import dataset
    EEG = import_data(input_dir, in_filename{i});
    load(fullfile(icamat_dir, in_filename_ica{i}));

    if EEG.srate > 500
       EEG = pop_resample(EEG, 500);
       EEG = eeg_checkset(EEG);
    end
    
    % high pass filtering
    if exist('hipass', 'var') && ~isempty(hipass)
        EEG = pop_eegfiltnew(EEG, hipass, 0);
        EEG = eeg_checkset(EEG);
    end
    
    % low pass filtering
    if exist('lowpass', 'var') && ~isempty(lowpass)
        EEG = pop_eegfiltnew(EEG, 0, lowpass);
        EEG = eeg_checkset(EEG);
    end

    % add channel locations
    EEG = add_chanloc(EEG, brain_template, on_ref, append_on_ref);

    % remove channels
    if ~isavg
        real_rm_chans = setdiff(rm_chans, off_ref);
    else
        real_rm_chans = rm_chans;
    end

    EEG = pop_select(EEG, 'nochannel', real_rm_chans);
    EEG = eeg_checkset(EEG);

    labels = {EEG.chanlocs.labels};
    % re-reference if necessary
    if ~isavg
        EEG = pop_reref(EEG, find(ismember(labels, off_ref)));
        EEG = eeg_checkset(EEG);
    else
        EEG = pop_reref(EEG, []);
        EEG = eeg_checkset(EEG);
    end

    % reject badchans
    EEG = pop_select(EEG, 'nochannel', union(ica.info.badchans, ica.info.rej_chan_by_epoch));
    
    % re-reference if offRef is average
    if isavg
        EEG = pop_reref(EEG, []);
        EEG = eeg_checkset(EEG);
    end

    % epoching
    EEG = pop_epoch(EEG, natsort(marks), epoch_time, 'epochinfo', 'yes');
    EEG = eeg_checkset(EEG);

    % baseline-zero
    EEG = pop_rmbase(EEG, []);

    % down-sampling
    EEG = pop_resample(EEG, srate);
    EEG = eeg_checkset(EEG);

    % reject epochs
    EEG = pop_rejepoch(EEG, ica.info.rej_epoch_auto, 0);
    
    % apply ica
    EEG = apply_ica(EEG, ica);
    
    % save datasets
    EEG = pop_saveset(EEG, 'filename', out_filename);
    
end
% eeglab redraw;
