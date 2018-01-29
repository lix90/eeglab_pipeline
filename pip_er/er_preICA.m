clear, clc, close all
base_dir = '~/Data/gender-role-emotion-regulation/';
input_tag = 'merge';
output_tag = 'preICA3';
file_ext = {'set', 'eeg'};
seperator = 1;

brain_template = 'Spherical';
on_ref = 'FCz';
append_on_ref = true;
off_ref = {'TP9', 'TP10', 'M2'};

srate = 250;
hipass = 1;
lowpass = [];
marks = {'S 11', 'S 22', 'S 33', 'S 44', 'S 55'};
epoch_time = [-0.5, 4];

flatline = 5;
mincorr = 0.4;
linenoisy = 4;

thresh_param.low_thresh = -500;
thresh_param.up_thresh = 500;
trends_param.slope = 200;
trends_param.r2 = 0.3;
spectra_param.threshold = [-35, 35];
spectra_param.freqlimits = [20 40];
joint_param.single_chan = 8;
joint_param.all_chan = 4;
kurt_param.single_chan = 8;
kurt_param.all_chan = 4;
thresh_chan = 0.1;
reject = 1;

%%------------------------
input_dir = fullfile(base_dir, input_tag);
output_dir = fullfile(base_dir, output_tag);
if ~exist(output_dir, 'dir'); mkdir(output_dir); end

[input_fname, id] = get_fileinfo(input_dir, file_ext);

rm_chans = {'HEOL', 'HEOR', 'HEOG', 'HEO', ...
            'VEOD', 'VEO', 'VEOU', 'VEOG', ...
            'M1', 'M2', 'TP9', 'TP10', ...
            'CB1', 'CB2'};

set_matlabpool(4);

parfor i = 1:numel(id)
    
    fprintf('dataset %i/%i: %s\n', i, numel(id), id{i});
    output_fname = sprintf('%s_%s.mat', id{i}, output_tag);
    output_fname_full = fullfile(output_dir, output_fname);
    if exist(output_fname_full, 'file')
        warning('files alrealy exist!')
        continue
    end
    
    ica = struct();
    
    % import dataset
    [EEG, ALLEEG, CURRENTSET] = import_data(input_dir, input_fname{i});
    
    EEG = filtering(EEG);
    
    EEG = add_chanloc(EEG);
    
    EEG = rej_chans(EEG, 'nonbrain');
    
    EEG = set_ref(EEG);

    orig_chanlocs = EEG.chanlocs;
    
    EEG = rej_chans(EEG, 'bad');
    bad_chans = {orig_chanlocs.labels};
    bad_chans = bad_chans(~EEG.etc.clean_channel_mask);
    
    if is_avgref(g.offline_ref)
        EEG = set_ref_avg(EEG);
    end

    % epoching
    EEG = pop_epoch(EEG, natsort(g.event_marks), g.event_timerange);
    EEG = eeg_checkset(EEG);
    
    % baseline-zero
    EEG = pop_rmbase(EEG, []);

    % down-sampling
    EEG = pop_resample(EEG, srate);
    EEG = eeg_checkset(EEG);
    
    try
        % reject epochs
        [EEG, info] = rej_epoch_auto(EEG, thresh_param, trends_param, spectra_param, ...
                                     joint_param, kurt_param, thresh_chan, ...
                                     reject);
        
        % run ica
        [ica.icawinv, ica.icasphere, ica.icaweights] = ...
            run_binica(EEG, is_avgref(g.offline_ref));
        
        ica.info = info;
        ica.info.bad_chans = bad_chans;
        ica.info.orig_chanlocs = orig_chanlocs;
        
        parsave2(output_fname_full, ica, 'ica', '-mat');
        
    catch
        
        fprintf('subj %i %s error!', i, id{i});
        
    end
    
    EEG = []; ALLEEG = []; CURRENTSET = [];
end
% eeglab redraw;
