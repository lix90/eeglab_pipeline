%% script for preprocessing before ICA
% 1. load channel location file
% 2. detrend
% 3. cleanline noise
% 4. remove bad channel
% 5. re-reference to m1-m2
% * manually check data
% 6. ica
% * manually check data
% 7. remove artifactual ICs (and compute pvaf of left ICs)
% 8. epoch into 4 epoches
% 9. frequency analysis (get relative power of rhythm activity)

baseDir = '~/Data/dingyi/';
inputDir = fullfile(baseDir, 'raw');
outputDir = fullfile(baseDir, 'pre_noRemoveWindows_1hz');
poolsize = 8;
% preprocessing parameters
ds = 250; % downsampling
hf = 1; % hi-pass filtering
loc = 'Spherical'; % channel loacation file type 'Spherical' or 'MNI'
rm = {'HEO', 'VEO', 'Trigger'};
rthresh = 0.5;
% onref = 'M1';
% ref = {'M1', 'M2'};
% eventfields = {'type', 'latency', 'duration'};
% timeunit = 0.001; % ms
    
% switch loc
%   case 'MNI'
%     locFile = 'standard_1005.elc';
%   case 'Spherical'
locFile = 'standard-10-5-cap385.elp';
% end 
eeglabDir = fileparts(which('eeglab.m'));
addpath(genpath(eeglabDir));
locDir = fullfile(eeglabDir, 'plugins', 'dipfit2.3', 'standard_BESA', locFile);
if ispc
    locDir = strrep(locDir, '\', '/');
end

if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
tmp = dir(fullfile(inputDir, '*.cnt'));
fileName = {tmp.name};
nFile = numel(fileName);
ID = get_prefix(fileName, 1);
ID = unique(ID);

if matlabpool('size')<poolsize
    matlabpool('local', poolsize);
end

parfor i = 1:nFile 
    ALLEEG = []; EEG = []; CURRENTSET = 0;
    % prepare output filename
    name = strcat('s', ID{i}, '_pre.set');
    outName = fullfile(outputDir, name);
    % check if file exists
    if exist(outName, 'file'); warning('files already exist'); continue; end
    EEG = pop_loadcnt(fullfile(inputDir, fileName{i}), ... 
                      'dataformat', 'auto', ...
                      'keystroke', 'on', 'memmapfile', '');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,...
                                         'setname',strcat('s', ID{i}),...
                                         'gui','off'); 
    % add channel locations
    EEG = pop_chanedit(EEG, 'lookup', locDir); % add channel location
    EEG = eeg_checkset(EEG);
    % M2/2
    iM2 = ismember({EEG.chanlocs.labels}, 'M2');
    m2 = EEG.data(iM2, :)/2;
    EEG.data(iM2, :) = m2;
    % re-reference to m2/2
    EEG = pop_reref(EEG, iM2);
    EEG = eeg_checkset(EEG);
    % downsampling
    EEG = pop_resample(EEG, ds);
    EEG = eeg_checkset(EEG);
    % hi-pass filtering
    EEG = pop_eegfiltnew(EEG, hf, []);
    EEG = eeg_checkset(EEG);
    % cleanline noise
    disp('cleanning line noise');
    lineNoiseIn = struct('lineNoiseChannels', [1:EEG.nbchan],...
                         'lineFrequencies', [50]);
    [EEG, lineNoiseOut] = cleanLineNoise(EEG, lineNoiseIn);
    % remove nonbrain channels
    rmidx = ismember({EEG.chanlocs.labels}, rm);
    EEG = pop_select(EEG, 'nochannel', find(rmidx));
    EEG = eeg_checkset(EEG);
    % backup channel location file
    EEG.etc.origchanlocs = EEG.chanlocs; 
    % remove bad channels
    arg_flatline = 5; % default is 5
    arg_highpass = 'off';
    arg_channel = 0.6; % default is 0.85
    arg_noisy = 4;
    arg_burst = 'off';
    arg_window = 'off';
    EEG = clean_rawdata(EEG, ...
                        arg_flatline, ...
                        arg_highpass, ...
                        arg_channel, ...
                        arg_noisy, ...
                        arg_burst, ...
                        arg_window);
    % chanLabels = {EEG.chanlocs.labels};
    % if isfield(EEGclean.etc, 'clean_channel_mask')
    %     EEG.etc.badChanLabelsASR = chanLabels(~EEGclean.etc.clean_channel_mask);
    %     EEG.etc.badChanLabelsASR
    %     EEG = pop_select(EEG, 'nochannel', find(~EEGclean.etc.clean_channel_mask));
    % else
    %     EEG.etc.badChanLabelsASR = {[]};
    % end
    % EEG = eeg_checkset(EEG);
    % EEGclean = [];
    
    % % re-reference
    % if strcmpi(ref, 'average')
    %     EEG = pop_reref(EEG, []);
    % elseif iscellstr(ref)
    %     indRef = ismember({EEG.chanlocs.labels}, ref);
    %     EEG = pop_reref(EEG, indRef);
    % end
    % EEG = eeg_checkset(EEG);
    % save dataset
    EEG = pop_saveset(EEG, 'filename', outName);
    EEG = []; 
end
