%addpath
eeglab_path = '/home/fengqiong/eeglab14_1_1b';
script_path = '/home/fengqiong/eeg_script_lix/dep';
addpath(genpath(eeglab_path));
addpath(genpath(script_path));

%% Preprocessing before ICA
g.base_dir = '~/data_processing/luoyudan_OCD_sst';
g.raw_folder = 'control'; 
g.ica_output_folder = 'ica'; 
g.postica_output_folder = 'postica'; 
g.split_output_folder = 'split_all';
g.file_ext = {'set', 'cnt'};

% Channel locations, re-referencing
g.brain_template = 'Spherical';
g.online_ref = 'M1';
g.append_online_ref = true;
g.offline_ref = {'M1', 'M2'};
g.veo = 'VEO';
g.heo = 'HEO';
g.rej_eo = true;
g.ica_on_epoched_data = true;
g.srate = 250;
g.high_hz = 1;
g.low_hz = [];
g.high_hz_erp = [];
g.low_hz_erp = [];
g.event_froms = {'20', '31', '32', '21', '33', '10', '11'};
g.event_tos = {'wrong', 'wrong', 'wrong', 'right', 'right', 'stop', 'go'};
g.change_latency_events = {'wrong', 'right'};
g.change_latency_latency = 1.5; % 1.5s
g.epoch_events = {'go', 'stop'};
g.epoch_eventnames = {''};
g.epoch_timerange = [-1, 2];
g.wrong_events = [];
g.resp_events = [];
g.resp_timewin = [];

%% Reject bad channels
g.flatline = 5;
g.mincorr = 0.4;
g.linenoisy = 4;

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
g.study_name = 'luoyudan_ocd_sst';
g.study_task = 'stop signal task';
g.study_notes = '';
