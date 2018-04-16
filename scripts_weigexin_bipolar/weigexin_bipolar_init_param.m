%addpath
eeglab_path = '/home/fengqiong/eeglab14_1_1b';
script_path = '/home/fengqiong/eeg_script_lix/dep';
addpath(genpath(eeglab_path));
addpath(genpath(script_path));

%% Preprocessing before ICA
g.base_dir = '~/data_processing/weigexin_bipolar_psychiatry_empathy';
g.raw_folder = 'merged'; 
g.ica_output_folder = 'ica'; 
g.postica_output_folder = 'postica'; 
g.split_output_folder = 'postica';
g.file_ext = {'set'};

% Channel locations, re-referencing
g.brain_template = 'Spherical';
g.online_ref = 'Cz';
g.append_online_ref = true;
g.offline_ref = {'TP9', 'TP10'};
g.veo = 'AF7';
g.heo = 'AF8';
g.rej_eo = false;
g.linenoise_freq = [50];
g.linenoise_bandwidth = [2];
g.srate = 250;
g.high_hz = 1;
g.low_hz = [];
g.high_hz_erp = 0.01;
g.low_hz_erp = [];
g.ica_on_epoched_data = false;
g.epoch_events = {'S 11', 'S 12', 'S 21', 'S 22'};
g.epoch_eventnames = {'explicit_pain', 'explicit_nopain', 'implicit_pain', 'implicit_nopain'};
g.epoch_timerange = [-1, 2];
g.wrong_events = [];
g.resp_events = [];
g.resp_timewin = [];

%% Reject bad channels
g.flatline = 5;
g.mincorr = 0.4;
g.linenoisy = [];

%% Automatically reject epoches
% Abnormal values
g.rejepoch.low_value = -500;
g.rejepoch.high_value = 500;
% Abnormal trends
g.rejepoch.slope = 200;
g.rejepoch.r2 = 0.3;
% Abnormal Spectrum
g.rejepoch.db_thresh = [-35, 35];
g.rejepoch.hz_thresh = [20 40];
% Joint Probability
g.rejepoch.joint_local = 8;
g.rejepoch.joint_global = 4;
% Kurtosis
g.rejepoch.kurt_local = 8;
g.rejepoch.kurt_global = 4;
% Reject channels by percentage of bad epoches in channel
g.rejepoch.perc_thresh = 0.1;

% Channels should be rejected
g.nonbrain_chans = {'FT9', 'FT10'};

%% reject components
g.rej_components = false;

%% create study
g.study_name = 'weigexin_bipolar_empathy';
g.study_task = 'pain empathy';
g.study_notes = '';
