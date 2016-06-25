%% pipeline codes for analysing eeg data of iris' pain empathy experiment
%% script for preprocessing before ICA
baseDir = '~/data/dingyi/';
inputDir = fullfile(baseDir, 'merge');
outputDir = fullfile(baseDir, 'pre');
poolsize = 2;
% preprocessing parameters
ds = 250; % downsampling
hf = 1; % hi-pass filtering
loc = 'Spherical'; % channel loacation file type 'Spherical' or 'MNI'
rm	= {'VEOG', 'HEOG', 'TP9', 'TP10'};
rthresh = 0.5;
onref = 'FCz';
ref = 'average';
CHANGE 	= true; % change event name
EPOCHTIME = [-1, 2]; % epoch time range
FROM 		= {'S 11', 'S 12', 'S 13', 'S 14',...
		   	   'S 21', 'S 22', 'S 23', 'S 24',...
		   	   'S 31', 'S 32', 'S 33', 'S 34'};
TO			= {'Old_Pain', 'Old_noPain', 'Old_Pain', 'Old_noPain', ...
		   	   'Adult_Pain', 'Adult_noPain', 'Adult_Pain', 'Adult_noPain', ...
		   	   'Child_Pain', 'Child_noPain', 'Child_Pain', 'Child_noPain'};
STIM 		= FROM;
RESP 		= {'S  7', 'S  8', 'S  9'};		

% switch loc
%   case 'MNI'
%     locFile = 'standard_1005.elc';
%   case 'Spherical'
locFile = 'standard-10-5-cap385.elp';
% end 
eeglabDir = fileparts(which('eeglab.m'));
locDir = fullfile(eeglabDir, 'plugins', 'dipfit2.3', 'standard_BESA', locFile);
if ispc
    locDir = strrep(locDir, '\', '/');
end

if ~exist(inputDir, 'dir'); disp('inputDir does not exist\n please reset it'); return; end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
tmp = dir(fullfile(inputDir, '*.edf'));
fileName = {tmp.name};
nFile = numel(fileName);
ID = get_prefix(fileName, 1);
ID = unique(ID);

if matlabpool('size')<poolsize
    matlabpool('local', poolsize);
end

parfor i = 1:nFile 
    % prepare output filename
    name = strcat('s', ID{i}, '_pre.set');
    outName = fullfile(outputDir, name);
    % check if file exists
    if exist(outName, 'file'); warning('files already exist'); continue; end 
    % load dataset
    EEG = pop_biosig(fullfile(inputDir, fileName{i}));
    % EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
    EEG = eeg_checkset(EEG); 
    % add events
    markFilename = fullfile(markDir, strcat('sub', int2str(i), '.txt'));
    EEG = pop_importevent( EEG, 'append', 'no', ...
                           'event', markFilename', ...
                           'fields', eventfields, ...
                           'timeunit', timeunit);
    EEG = eeg_checkset( EEG ); 
    % add channel locations
    EEG = pop_chanedit(EEG, 'lookup', locDir); % add channel location
    EEG = eeg_checkset(EEG);
    nchan = size(EEG.data, 1);
    EEG = pop_chanedit(EEG, 'append', nchan, ...
                       'changefield', {nchan+1, 'labels', onref}, ...
                       'lookup', locDir, ...
                       'setref', {['1:',int2str(nchan+1)], onref}); % add online reference
    EEG = eeg_checkset(EEG);
    outStruct = struct('labels', onref,...
                       'type', [],...
                       'theta', [],...
                       'radius', [],...
                       'X', [],...
                       'Y', [],...
                       'Z', [],...
                       'sph_theta', [],...
                       'sph_phi', [],...
                       'sph_radius', [],...
                       'urchan', nchan+1,...
                       'ref', onref,...
                       'datachan', {0});
    EEG = pop_reref(EEG, [], 'refloc', outStruct); % retain online reference data back
    EEG = eeg_checkset(EEG);
    EEG = pop_chanedit(EEG, 'lookup', locDir, ...
                       'setref', {['1:', int2str(size(EEG.data, 1))] 'average'});
    EEG = eeg_checkset(EEG);
    chanlocs = pop_chancenter(EEG.chanlocs, []);
    EEG.chanlocs = chanlocs;
    EEG = eeg_checkset(EEG); 
    % downsampling
    EEG = pop_resample(EEG, ds);
    EEG = eeg_checkset(EEG);
    % hi-pass filtering
    EEG = pop_eegfiltnew(EEG, hf, []);
    EEG = eeg_checkset(EEG);
    % cleanline noise
% $$$          disp('cleanning line noise');
% $$$          lineNoiseIn = struct('lineNoiseChannels', [1:EEG.nbchan],...
% $$$                               'lineFrequencies', [50]);
% $$$          [EEG, lineNoiseOut] = cleanLineNoise(EEG, lineNoiseIn);
% re-reference m1-m2
% $$$                                 refidx = find(ismember({EEG.chanlocs.labels}, ref));
% $$$                                 EEG = pop_reref(EEG, refidx);
% $$$                                 EEG = eeg_checkset(EEG);
% remove nonbrain channels
    rmidx = ismember({EEG.chanlocs.labels}, rm);
    EEG = pop_select(EEG, 'nochannel', find(rmidx));
    EEG = eeg_checkset(EEG);
    % backup channel location file
    EEG.etc.origchanlocs = EEG.chanlocs; 
    % remove bad channels
    arg_flatline = 5; % default is 5
    arg_highpass = 'off';
    arg_channel = rthresh; % default is 0.85
    arg_noisy = [];
    arg_burst = 'off';
    arg_window = 'off';
    EEGclean = clean_rawdata(EEG, ...
                             arg_flatline, ...
                             arg_highpass, ...
                             arg_channel, ...
                             arg_noisy, ...
                             arg_burst, ...
                             arg_window);
    chanLabels = {EEG.chanlocs.labels};
    if isfield(EEGclean.etc, 'clean_channel_mask')
        EEG.etc.badChanLabelsASR = chanLabels(~EEGclean.etc.clean_channel_mask);
        EEG.etc.badChanLabelsASR
        EEG = pop_select(EEG, 'nochannel', find(~EEGclean.etc.clean_channel_mask));
    else
        EEG.etc.badChanLabelsASR = {[]};
    end
    EEG = eeg_checkset(EEG);
    EEGclean = []; 
    if strcmpi(ref, 'average')
        EEG = pop_reref(EEG, []);
    elseif iscellstr(ref)
        indRef = ismember({EEG.chanlocs.labels}, ref);
        EEG = pop_reref(EEG, indRef);
    end
    EEG = eeg_checkset(EEG); 
    % change events
    EEG = readable_event(EEG, RESP, STIM, CHANGE, FROM, TO);
    % epoch
    if CHANGE
        MARKS = unique(TO);
    else
        MARKS = unique(FROM);
    end
    EEG = pop_epoch(EEG, MARKS, EPOCHTIME);
    % remove baseline
    EEG = pop_rmbase(EEG, []);
    EEG = eeg_checkset(EEG);
    EEG = pop_saveset(EEG, 'filename', outName);
    EEG = []; 
end
