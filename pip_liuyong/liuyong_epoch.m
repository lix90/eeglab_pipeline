clear, clc, close all
base_dir = '';
input_folder = 'raw';
output_folder = 'epoch';
ica_folder = 'ica';
output_prefix = 'subj';
output_sufix = 'epoch';
file_ext = {'eeg'};
sep_position = 1;

brainTemplate = 'Spherical';
onlineRef = 'FCz';
appendOnlineRef = true;
offlineRef = {'TP9', 'TP10'};
sampleRate = 250;

marks = {'S 55'};
wrong_resp = {''}; % if not, make it []
timeRange = [-5, 5];
hipass = 0.1; % if ERP, it must be less 0.1Hz; otherwise, it can be 1Hz or above.
lowpass = 40;

use_auto_identify_ic = 0;
EOG = [];
rejIC = 0;

%%--------------
input_dir = fullfile(base_dir, input_folder);
output_dir = fullfile(base_dir, output_folder);
ica_dir = fullfile(base_dir, ica_folder);
if ~exist(output_dir, 'dir'); mkdir(output_dir); end

[inputFilename, id] = get_fileinfo(input_dir, file_ext, sep_position);

rmChans = {'HEOL', 'HEOR', 'HEOG', 'HEO', ...
           'VEOD', 'VEO', 'VEOU', 'VEOG', ...
           'M1', 'M2', 'TP9', 'TP10'};

set_matlabpool(4);
parfor i = 1:numel(id)

    fprintf('subj %i/%i: %s', i, numel(id), id{i});
    if ~exist(output_prefix, 'var') || isempty(output_prefix)
        outputFilename = sprintf('%s_%s.set', id{i}, output_sufix);
    else
        outputFilename = sprintf('%s%s_%s.set', output_prefix, id{i}, ...
                                 output_sufix);
    end
    outputFilenameFull = fullfile(output_dir, outputFilename);
    
    if exist(outputFilenameFull, 'file')
        warning('files alrealy exist!')
        continue
    end

    % load icamat
    if ~exist(output_prefix, 'var') || isempty(output_prefix)
        ica_file = sprintf('%s_%s.mat', id{i}, ica_folder);
    else
        ica_file = sprintf('%s%s_%s.mat', output_prefix, id{i}, ica_folder);
    end
    data = parload(fullfile(ica_dir, ica_file));
        
    % import dataset
    [EEG, ALLEEG, CURRENTSET] = import_data(input_dir, inputFilename{i});
    
    % add channel locations
    EEG = add_chanloc(EEG, brainTemplate, onlineRef, appendOnlineRef);
    
    % remove channels
    if ~strcmp(offlineRef, 'average')
        rmChansReal = setdiff(rmChans, offlineRef);
    else
        rmChansReal = rmChans;
    end
    
    EEG = pop_select(EEG, 'nochannel', rmChansReal);
    EEG = eeg_checkset(EEG);
    
    labels = {EEG.chanlocs.labels};

    % re-reference if necessary
    if ~strcmp(offlineRef, 'average')
        offlineRefReal = intersect(labels, offlineRef);
        if strcmpi(char(offlineRefReal), 'm2')
            indexM2 = find(ismember(labels, offlineRefReal));
            EEG.data(indexM2, :) = EEG.data(indexM2, :)/2;
        end
        EEG = pop_reref(EEG, find(ismember(labels, offlineRefReal)));
        EEG = eeg_checkset(EEG);
    elseif strcmp(offlineRef, 'average')
        EEG = pop_reref(EEG, []);
        EEG = eeg_checkset(EEG);
    elseif isempty(offlineRef)
        disp('not to be re-referenced')
    end
    
    % high pass filtering
    if ~isempty(hipass)
        EEG = pop_eegfiltnew(EEG, hipass, 0);
        EEG = eeg_checkset(EEG);
    end
    
    if ~isempty(lowpass)
        EEG = pop_eegfiltnew(EEG, 0, lowpass);
        EEG = eeg_checkset(EEG);
    end
    
    % reject bad channels
    labels = {EEG.chanlocs.labels};
    ica = data.ica;
    badchans = union(ica.info.rej_chan_by_epoch, ica.info.badchans);
    if ~empty(badchans)
        EEG = pop_select(EEG, 'nochannel', find(ismember(labels, ...
                                                         badchans)));
    end
    
    % re-reference if offRef is average
    if strcmp(offlineRef, 'average')
        EEG = pop_reref(EEG, []);
        EEG = eeg_checkset(EEG);
    end

    % epoching
    EEG = pop_epoch(EEG, natsort(marks), timeRange, 'epochinfo', 'yes');
    EEG = eeg_checkset(EEG);

    % down-sampling
    EEG = pop_resample(EEG, sampleRate);
    EEG = eeg_checkset(EEG);
    
    % baseline-zero
    EEG = pop_rmbase(EEG, []);
    EEG = eeg_checkset(EEG);

    % reject epochs
    EEG = pop_rejepoch(EEG, ica.info.rej_epoch_auto, 0);
    EEG = eeg_checkset(EEG);
        
    % reject wrong response
    if ~isempty(wrong_resp)
        rej_wrong_resp = rej_wrong(EEG, wrong_resp); 
        EEG = pop_rejepoch(EEG, rej_wrong_resp, 0);
        EEG = eeg_checkset(EEG);
    end
        
    EEG.etc.info = ica.info;
    EEG.icawinv = ica.icawinv;
    EEG.icasphere = ica.icasphere;
    EEG.icaweights = ica.icaweights;
    EEG = eeg_checkset(EEG, 'ica');
    
    %% reject ICs
    if use_auto_identify_ic
        EEG = rej_SASICA(EEG, EOG, rejIC);
    end
    
    EEG = pop_saveset(EEG, 'filename', outputFilenameFull);
    EEG = []; ALLEEG = []; CURRENTSET = [];

end
