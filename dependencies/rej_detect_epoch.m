function [epoch_index, bad_chans] = rej_detect_epoch(EEG, rejepoch)
% Automatically detect bad epochs to reject
% 
% Example:
% 
% [epoch_index, bad_chans] = rej_detect_epoch(EEG, rejepoch);
%
% Input Parameters:
%
% - EEG, eeglab EEG struct
% - rejepoch, a struct of a set of threshold to detect bad epochs
% - rejepoch.low_value: default is -500;
% - rejepoch.high_value: default is 500;
% - rejepoch.slope: default is 200;
% - rejepoch.r2: default is 0.3;
% - rejepoch.db_thresh: default is [-35, 35];
% - rejepoch.hz_thresh: default is [20 40];
% - rejepoch.joint_local: default is 8;
% - rejepoch.joint_global: default is 4;
% - rejepoch.kurt_local: default is 8;
% - rejepoch.kurt_global: default is 4;
% - rejepoch.perc_thresh: default is 0.1;
%
% Output Parameters:
%
% - epoch_index: index of bad epochs;
% - bad_chans: labels of bad chans identified by the threshold of percentage
% of bad epochs.
    
    old_chanlabels = {EEG.chanlocs.labels};
    tmp = true;
    if isfield(rejepoch, 'perc_thresh')
        while tmp
            [rejE, rejG] = detect_epoch(EEG, rejepoch);
            perc = sum(rejE,2)/EEG.trials;
            chanrej = find(perc >= rejepoch.perc_thresh);
            % Write log
            EEG = pop_select(EEG, 'nochannel', chanrej);
            EEG = eeg_checkset(EEG);
            if isempty(chanrej)
                tmp = false;
            end
        end
    else
        [rejE, rejG] = detect_epoch(EEG, rejepoch);
    end
    new_chanlabels = {EEG.chanlocs.labels};
    
    epoch_index = rejG;
    bad_chans = setdiff(old_chanlabels, new_chanlabels);

function [rejE, rejG] = detect_epoch(EEG, rejepoch)
    
    if all(isfield(rejepoch, {'low_value', 'high_value'}))
        EEG = rej_epoch_by_thresh(EEG, rejepoch.low_value, rejepoch.high_value);
    end

    if all(isfield(rejepoch, {'slope', 'r2'}))
        EEG = rej_epoch_by_trends(EEG, rejepoch.slope, rejepoch.r2);
    end

    if all(isfield(rejepoch, {'db_thresh', 'hz_thresh'}))
        EEG = rej_epoch_by_spectra(EEG, rejepoch.db_thresh, rejepoch.hz_thresh);
    end

    if all(isfield(rejepoch, {'kurt_local', 'kurt_global'}))
        EEG = rej_epoch_by_kurtosis(EEG, rejepoch.kurt_local, rejepoch.kurt_global);
    end

    if all(isfield(rejepoch, {'joint_local', 'joint_global'}))
        EEG = rej_epoch_by_jointprob(EEG, rejepoch.joint_local, rejepoch.joint_global);
    end
    
    [rejE, rejG] = rej_superpose(EEG);
  
