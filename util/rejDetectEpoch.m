function EEG = rejDetectEpoch(EEG, thresh_param, trends_param, spectra_param)

if ~isempty(thresh_param) && any(isfield(thresh_param, {'low_thresh', 'up_thresh'}))
    % find abnormal values
    fprintf('start: detect bad epochs by abnormal values\n');
    low_thresh = thresh_param.low_thresh;
    up_thresh = thresh_param.up_thresh;
    EEG = pop_eegthresh(EEG,1,1:EEG.nbchan,low_thresh,up_thresh,EEG.xmin,EEG.xmax, ...
                        0, 0);
    EEG = eeg_checkset(EEG);
end
if ~isempty(trends_param)
    % find abnormal trends
    fprintf('start: detect bad epochs by abnormal trends\n');
    slope = trends_param.slope;
    r2 = trends_param.r2;
    winsize = EEG.pnts;
    step = 1;
    EEG = pop_rejtrend(EEG, 1, [1:EEG.nbchan], EEG.pnts, slope, r2, 0, 0, 0);
    EEG = eeg_checkset(EEG);
    %             [EEG.reject.rejconst, EEG.reject.rejconstE] = ...
    %                 rejtrend(EEG.data, winsize, slope, r2, step);

end
if ~isempty(spectra_param) && any(isfield(spectra_param, {'threshold', 'freqlimits'}))
    % find abnormal spectra
    fprintf('start: detect bad epochs by abnormal spectra\n');
    threshold = spectra_param.threshold;
    freqlimits = spectra_param.freqlimits;
    EEG = pop_rejspec_noplot(EEG, 1, 'elecrange', [1:EEG.nbchan], 'threshold', threshold,...
                             'freqlimits', freqlimits, 'eegplotcom', '', ...
                             'eegplotreject', 0, 'eegplotplotallrej', 0);
    EEG = eeg_checkset(EEG);
end
fprintf('start superpose marked epochs\n');
EEG = eeg_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1);
EEG = eeg_checkset(EEG);
