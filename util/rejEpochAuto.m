function [EEG, info] = rejEpochAuto(EEG, thresh_param, trends_param, spectra_param, threshChan, reject)

    info.orig_ntrial = EEG.trials;
    info.orig_chanlocs = EEG.chanlocs;
    % identify epoch
    EEG = autoRejEpoch(EEG, thresh_param, trends_param, spectra_param);
    if ~isempty(EEG.reject.rejglobalE) && exist('threshChan', 'var')
        perBadEpochInChannels = sum(EEG.reject.rejglobalE, 2)/EEG.trials;
        rej_ch_by_epoch = find(perBadEpochInChannels > threshTrialPerChan);
        if ~isempty(rej_chn_by_epoch)
            EEG = pop_select(EEG, 'nochannel', rej_ch_by_epoch);
            EEG = eeg_checkset(EEG);
            % identify epoch again
            EEG = autoRejEpoch(EEG, thresh_param, trends_param, spectra_param);
        end
    end
    
    if reject
        indexRej = EEG.reject.rejglobal;
        EEG = pop_rejepoch(EEG, indexRej ,0);
    end
    
    info.rej_epoch_auto = EEG.reject.rejglobal;
    labels = {info.orig_chanlocs.labels};
    info.rej_chan_by_epoch = labels(rej_ch_by_epoch);

    function EEG = autoRejEpoch(EEG, thresh_param, trends_param, spectra_param)

        if ~isempty(thresh_param) && isfield(thresh_param, {'low_thresh', 'up_thresh'})
            % find abnormal values    
            low_thresh = thresh_param.low_thresh;
            up_thresh = thresh_param.up_thresh;
            EEG = pop_eegthresh(EEG,1,1:EEG.nbchan,low_thresh,up_thresh,EEG.xmin,EEG.xmax, ...
                                0, 0);
        end
        if ~isempty(trends_param)
            % find abnormal trends
            slope = trends_param.slope;
            r2 = trends_param.r2;
            winsize = EEG.pnts;
            step = 1;
            [EEG.reject.rejconst, EEG.reject.rejconstE] = ...
                rejtrend(EEG.data, winsize, slope, r2, step);
         
        end
        if ~isempty(spectra_param) && isfield(spectra_param, {'threshold', 'freqlimits'})
            % find abnormal spectra
            threshold = spectra_param.threshold;
            freqlimits = spectra_param.freqlimits;
            EEG = pop_rejspec(EEG, 1, 'elecrange', [], 'threshold', threshold,...
                              'freqlimits', freqlimits, 'eegplotcom', [], ...
                              'eegplotreject', 0, 'eegplotplotallrej', 0);
        end
        EEG = pop_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1);
        EEG = eeg_checkset(EEG);
