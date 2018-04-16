%addpath
eeglab_path = '/home/fengqiong/eeglab14_1_1b';
script_path = '/home/fengqiong/eeg_script_lix/dep';
addpath(genpath(eeglab_path));
addpath(genpath(script_path));

%% Preprocessing before ICA
g.base_dir = '~/data_processing/chenfangfang_autismtraits_IGT';
g.raw_folder = 'autismhigh'; 
g.ica_output_folder = 'ica_autismhigh'; 
g.postica_output_folder = 'postica_autismhigh'; 
g.split_output_folder = 'postica_autismhigh';
g.file_ext = {'cnt'};

% Channel locations, re-referencing
g.brain_template = 'Spherical';
g.online_ref = 'M1';
g.append_online_ref = true;
g.offline_ref = {'M1', 'M2'};
g.veo = 'VEO';
g.heo = 'HEO';
g.linenoise_freq = [];
g.linenoise_bandwidth = [];
g.srate = 250;
g.high_hz = 1;
g.low_hz = [];
g.high_hz_erp = [];
g.low_hz_erp = [];
g.ica_on_epoched_data = true;
g.epoch_events = {'50', '51', '100', '101'};
g.epoch_eventnames = {'advantage_loss', 'advantage_win', ...
    'disadvantage_loss', 'disadvantage_win'};
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
g.nonbrain_chans = {'CB1', 'CB2'};

%% reject components
g.rej_components = false;

%% create study
g.study_name = 'chenfangfang_autismtraits_igt';
g.study_task = 'the revised iowa gambling task';
g.study_notes = '';
