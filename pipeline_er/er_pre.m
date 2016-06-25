%% script for preprocessing: before ica

%%%%%% parameters initialization

% prepare directory
baseDir = '~/Data/gender-role-emotion-regulation/'; % directory storing data
inputDir = fullfile(baseDir, 'merge_old'); % input directory: 'merge' or 'raw'
outputDir = fullfile(baseDir, 'pre');
fileExt = 'set'; % file extension: 'eeg' or 'set'
                 % poolSize = 4; % how many cores do you want to use?
                 % 4 is good if your computer has enough memory

% preprocessing parameters
DS			= 250; % downsampling frequency
HP 			= 1; % high-pass filtering 
                 % e.g. default 1hz hi-pass filtering is 
                 % 0.5Hz cutoff frequency at -6dB
MODEL  	= 'Spherical'; % channel loacation file type 'Spherical' or 'MNI'
                       % which one you prefer? 
UNUSED	= {'HEOL', 'HEOR', 'VEOD', 'VEOU', 'M2'}; % labels of channels you do not use
                                                  % e.g. electrodes recording
                                                  % non-brain signal
                                                  % UNUSED = {'HEOR', 'VEO', 'TP9', 'TP10'};
CHANTHRESH = 0.5; % parameter for reject bad channels,
                  % you do not need to change it, unless not satisfy with 
                  % results of detecting bad channels

% epoching parameters
REF = 'average'; % offline rereference electrodes
ONREF 	= []; %'FCz'; % online reference electrodes to
              % restore
EPOCHTIME = [-1, 5]; % epoch time range
FROM	= {'S 11', 'S 22', 'S 33', 'S 44', 'S 55'}; % original marks of
                                                    % stimulus
TO = {'free', 'suppresion', 'change_view', 'free_neutral', 'change_suppression'};
CHANGE = true;

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
lix_matpool(4);

%%%%%% start for loop
parfor i = 1:nFile
    % for i = 1              
    EEG = [];
    %%%%%% prepare output filename
    name = strcat(ID{i}, '_pre.set');
    outName = fullfile(outputDir, name);
    if exist(outName, 'file'); warning('files already exist'); continue; end
    
    %%%%%% load dataset
    switch fileExt
      case 'set'
        EEG = pop_loadset('filename', fileName{i}, 'filepath', inputDir);
      case 'eeg'
        EEG = pop_fileio(fullfile(inputDir, fileName{i}));
    end
    EEG = eeg_checkset(EEG);

    %%%%%% add channel locations
    EEG = pop_chanedit(EEG, 'lookup', locDir); % add channel location
    EEG = eeg_checkset(EEG);
    nbchan = size(EEG.data, 1);
    if ~isempty(ONREF)
        % add online reference
        EEG = pop_chanedit(EEG, 'lookup', locDir); % add channel location
        EEG = eeg_checkset(EEG);
        nchan = size(EEG.data, 1);
        EEG = pop_chanedit(EEG, 'append', nchan, ...
                           'changefield',{nchan+1, 'labels', ONREF}, ...
                           'lookup', locDir, ...
                           'setref',{['1:',int2str(nchan+1)], ONREF}); % add online reference
        EEG = eeg_checkset(EEG);
        outStruct = chanLocCreate(ONREF, nchan+1);
        EEG = pop_reref(EEG, [], 'refloc', outStruct); % retain online reference data back
        EEG = eeg_checkset(EEG);
        EEG = pop_chanedit(EEG, 'lookup', locDir, 'setref',{['1:', int2str(size(EEG.data, 1))] 'average'});
        EEG = eeg_checkset(EEG);
        chanlocs = pop_chancenter(EEG.chanlocs, []);
        EEG.chanlocs = chanlocs;
        EEG = eeg_checkset(EEG);
    end
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
    if iscellstr(REF)
        chanLabels = {EEG.chanlocs.labels};
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

    % if average reference, rereference again
    if strcmp(REF, 'average')
        EEG = pop_reref(EEG, []);
        EEG = eeg_checkset(EEG);
    end
    
    try
        %% change events
        % EEG = readable_event(EEG, RESP, STIM, CHANGE, FROM, TO);
        if CHANGE
            EEG = lix_change_event(EEG, FROM, TO);
        end
    
        %% epoch
        if CHANGE
            MARKS = unique(TO);
        else
            MARKS = unique(FROM);
        end
        EEG = pop_epoch(EEG, MARKS, EPOCHTIME);
        EEG = eeg_checkset(EEG);


        %%%%%% save dataset
        EEG = pop_saveset(EEG, 'filename', outName);
    catch
        continue
    end
end

