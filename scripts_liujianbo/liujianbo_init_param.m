%addpath
%eeglab_path = '/home/fengqiong/eeglab14_1_1b';
% script_path = '/home/fengqiong/eeg_script_lix/dep';
% addpath(genpath(eeglab_path));
% addpath(genpath(script_path));

%% Preprocessing before ICA
g.base_dir = '~/Downloads/jb_erp';
g.raw_folder = 'raw';
g.rename_folder = 'rename';
g.text_folder = 'stim';
g.ica_output_folder = 'ica'; 
g.postica_output_folder = 'postica'; 
g.split_output_folder = 'split';
g.output_folder = 'export_erp';
g.file_ext = {'set', 'cnt'};

% Channel locations, re-referencing
%g.brain_template = 'Spherical';
%g.online_ref = 'M1';
%g.append_online_ref = true;
%g.offline_ref = {'M1', 'M2'};
g.veo = 'E5'; % 5,10,62,63
g.heo = 'E61'; % 61,64
g.rej_eo = true;
g.ica_on_epoched_data = true;
g.srate = 250;
g.high_hz = 1;
g.low_hz = [];
g.high_hz_erp = [];
g.low_hz_erp = [];
g.linenoise_freq = [50];
g.linenoise_bandwidth = 1;
% happy是1、2angry是3、4fear是5、6disgust是7、8
g.event_froms = {'1', '2', '3', '4', '5', '6', '7', '8'};
g.event_tos = {'happy', 'happy', ...
               'angry', 'angry', ...
               'fear', 'fear', ...
               'disgust', 'disgust'};
%g.change_latency_events = {'wrong', 'right'};
%g.change_latency_latency = 1.5; % 1.5s
g.epoch_events = {'happy', 'angry', 'fear', 'disgust'};
g.epoch_eventnames = {''};
g.epoch_timerange = [-1, 2.8];
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
g.nonbrain_chans = {''};

%% reject components
g.rej_components = false;

%% create study
g.study_name = 'liujianbo_emotion';
g.study_task = 'dot probe task';
g.study_notes = '';
