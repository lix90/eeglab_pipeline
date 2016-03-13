%% script for preprocessing: before ica

%%%%%% parameters initialization

% prepare directory
baseDir = ''; % directory storing data
inputDir = fullfile(baseDir, 'merge'); % input directory: 'merge' or 'raw'
outputDir = fullfile(baseDir, 'pre');
fileExt = 'eeg'; % file extension: 'eeg' or 'set'
poolSize = 4; % how many cores do you want to use?
              % 4 is good if your computer has enough memory

% preprocessing parameters
DS			= 250; % downsampling frequency
HP 			= 1; % high-pass filtering 
             % e.g. default 1hz hi-pass filtering is 
             % 0.5Hz cutoff frequency at -6dB
MODEL  	= 'Spherical'; % channel loacation file type 'Spherical' or 'MNI'
                       % which one you prefer? 
UNUSED	= {'VEO', 'HEOR'}; % labels of channels you do not use
                           % e.g. electrodes recording non-brain signal
CHANTHRESH = 0.5; % parameter for reject bad channels,
                  % you do not need to change it, unless not satisfy with 
                  % results of detecting bad channels

% epoching parameters
REF			= {'TP9', 'TP10'}; % offline rereference electrodes
ONREF 	= 'FCz'; % online reference electrodes to restore
EPOCHTIME = [-1, 2]; % epoch time range
EPOCHNAME	= {'S  3', 'S  6', 'S  7'}; % original marks of stimulus
RESP 		= {'S  7', 'S  8', 'S  9'};		% marks of responses 

%%%%%% check directory
if ~exist(inputDir, 'dir')
    disp('inputDir does not exist\n please reset it'); 
    return
end
if ~exist(outputDir, 'dir'); mkdir(outputDir); end

%%%%%% channel location files
switch MODEL
	case 'MNI'
		locFile = 'standard_1005.elc';
	case 'Spherical'
		locFile = 'standard-10-5-cap385.elp';
end
locDir = which(locFile);
if ispc
    locDir = strrep(locDir, '\', '/');
end

%%%%%% prepare datasets
tmp = dir(fullfile(inputDir, ['*.', fileExt]));
fileName = natsort({tmp.name});
nFile = numel(fileName);
ID = get_prefix(fileName, 1);
ID = natsort(unique(ID));

%%%%%% Open matlab pool
poolsize_check = matlabpool('size');
if poolsize_check==0
	matlabpool('local', poolSize);
elseif poolsize_check > 0 && poolsize_check ~= poolSize
	matlabpool close force;
	matlabpool('local', poolSize);
end

%%%%%% start for loop
parfor i = 1:nFile
    
    %%%%%% prepare output filename
    name = strcat(ID{i}, '_pre.set');
    outName = fullfile(outputDir, name);
    if exist(outName, 'file'); warning('files already exist'); continue; end
    
    %%%%%% load dataset
    switch fileExt
    case 'set'
        EEG = pop_loadset('filename', tmpFileName, 'filepath', inputDir);
    case 'eeg'
        EEG = pop_fileio('filename', fullfile(inputDir, tmpFileName));
    end
    EEG = eeg_checkset(EEG);

    %%%%%% add channel locations
    EEG = pop_chanedit(EEG, 'lookup', locDir); % add channel location
    EEG = eeg_checkset(EEG);
    nchan = size(EEG.data, 1);
    % add online reference
    EEG = pop_chanedit(EEG, 'append', nchan, ...
                       'changefield',{nchan+1, 'labels', ONREF}, ...
                       'lookup', locDir, ...
                       'setref',{['1:',int2str(nchan+1)], ONREF}); 
    EEG = eeg_checkset(EEG);
    outStruct = struct('labels', nbchan+1,...
                       'type', [],...
                       'theta', [],...
                       'radius', [],...
                       'X', [],...
                       'Y', [],...
                       'Z', [],...
                       'sph_theta', [],...
                       'sph_phi', [],...
                       'sph_radius', [],...
                       'urchan', nbchan+1,...
                       'ref', ONREF,...
                       'datachan', {0});
    % retain online reference data back
    EEG = pop_reref(EEG, [], 'refloc', outStruct); 
    EEG = eeg_checkset(EEG);
    EEG = pop_chanedit(EEG, 'lookup', locDir, ...
                       'setref', {['1:', int2str(size(EEG.data, 1))] 'average'});
    EEG = eeg_checkset(EEG);
    chanlocs = pop_chancenter(EEG.chanlocs, []);
    EEG.chanlocs = chanlocs;
    EEG = eeg_checkset(EEG);

    %%%%%% remove nonbrain channels
    chanLabels = {EEG.chanlocs.labels};
    idx = find(ismember(chanLabels, UNUSED));
    EEG = pop_select(EEG, 'nochannel', idx);
    EEG = eeg_checkset(EEG);

    %%%%%% downsampling
    EEG = pop_resample(EEG, DS);
    EEG = eeg_checkset(EEG);

    %%%%%% high pass filtering: 
    % 1 Hz for better ica results, but not proper for erp study
    EEG = pop_eegfiltnew(EEG, HP, []); 
    EEG = eeg_checkset(EEG);
    
    %%%%%% re-reference
    chanLabels = {EEG.chanlocs.labels};
    if strcmpi(REF, 'average')
        EEG = pop_reref(EEG, []);
    elseif iscellstr(REF)
        indRef = find(ismember(chanLabels, REF));
        EEG = pop_reref(EEG, indRef);
    end
    EEG = eeg_checkset(EEG);

    %%%%%% remove bad channels
    arg_flatline = 5; % default is 5
    arg_highpass = 'off';
    arg_channel = CHANTHRESH; % default is 0.85
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

    % if average reference, rereference again
    if strcmp(REF, 'average')
        EEG = pop_reref(EEG, []);
        EEG = eeg_checkset(EEG);
    end
    
    %%%%%% epoch
    EEG = pop_epoch(EEG, EPOCHNAME, EPOCHTIME);
    EEG = eeg_checkset(EEG);

    %%%%%% save dataset
    EEG = pop_saveset(EEG, 'filename', outName);
    EEG = [];

end

