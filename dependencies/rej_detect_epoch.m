function EEG = rej_detect_epoch(EEG, thresh_param, trends_param, spectra_param, ...
                                joint_param, kurt_param, thresh_chan)

%% code
if ~isempty(thresh_param) && all(isfield(thresh_param, {'low_thresh', 'up_thresh'}))
    % find abnormal values
    fprintf('start: detect bad epochs by abnormal values\n');
    low_thresh = thresh_param.low_thresh;
    up_thresh = thresh_param.up_thresh;
    [~, rej_thresh, ~, rej_threshE] = ...
        eegthresh(EEG.data, EEG.pnts, 1:EEG.nbchan, low_thresh, up_thresh, ...
                  [EEG.xmin, EEG.xmax], EEG.xmin, EEG.xmax);
    rejthresh_tmp = zeros(1, EEG.trials);
    rejthresh_tmp(rej_thresh) = 1;
    EEG.reject.rejthresh = rejthresh_tmp;
    rejthreshE_tmp = zeros(EEG.nbchan, EEG.trials);
    rejthreshE_tmp(:, rej_thresh) = rej_threshE;
    EEG.reject.rejthreshE = rejthreshE_tmp;
    % EEG = pop_eegthresh(EEG,1,1:EEG.nbchan,low_thresh,up_thresh,EEG.xmin,EEG.xmax, ...
    %                     0, 0);
    EEG = eeg_checkset(EEG);
    fprintf('%d/%d trial(s) marked for rejection\n', length(rej_thresh), ...
            EEG.trials);
end

if ~isempty(trends_param) && all(isfield(trends_param, {'slope', 'r2'}))
    % find abnormal trends
    fprintf('start: detect bad epochs by abnormal trends\n');
    slope = trends_param.slope;
    r2 = trends_param.r2;
    winsize = EEG.pnts;
    step = 1;
    % EEG = pop_rejtrend(EEG, 1, [1:EEG.nbchan], EEG.pnts, slope, r2, 0, 0, 0);
    % EEG = eeg_checkset(EEG);
    [EEG.reject.rejconst, EEG.reject.rejconstE] = ...
        rejtrend(EEG.data, winsize, slope, r2, step);
    fprintf('%d/%d trial(s) marked for rejection\n', ...
            length(find(EEG.reject.rejconst>0)), EEG.trials);
    EEG = eeg_checkset(EEG);
end

if ~isempty(spectra_param) && all(isfield(spectra_param, {'threshold', 'freqlimits'}))
    % find abnormal spectra
    fprintf('start: detect bad epochs by abnormal spectra\n');
    threshold = spectra_param.threshold;
    freqlimits = spectra_param.freqlimits;
    method = 'multitaper';
    [~, rej_spec, rej_specE, ~] = rej_spectra(EEG.data, [], 1:EEG.nbchan, EEG.srate, ...
                                              threshold(1), threshold(2), ...
                                              freqlimits(1), freqlimits(2), ...
                                              method);
    % EEG = pop_rejspec_noplot(EEG, 1, 'elecrange', [1:EEG.nbchan], 'threshold', threshold,...
    %                          'freqlimits', freqlimits, 'eegplotcom', '', ...
    %                          'eegplotreject', 0, 'eegplotplotallrej', 0);
    EEG = eeg_checkset(EEG);
    rejspec_tmp = zeros(1, EEG.trials);
    rejspec_tmp(rej_spec) = 1;
    EEG.reject.rejfreq = rejspec_tmp;
    rejspecE_tmp = zeros(EEG.nbchan, EEG.trials);
    rejspecE_tmp(:, rej_spec) = rej_specE;
    EEG.reject.rejfreqE = rejspecE_tmp;
    % EEG = pop_eegthresh(EEG,1,1:EEG.nbchan,low_thresh,up_thresh,EEG.xmin,EEG.xmax, ...
    %                     0, 0);
    EEG = eeg_checkset(EEG);
    fprintf('%d/%d trial(s) marked for rejection\n', length(rej_spec), ...
            EEG.trials);
end

if ~isempty(joint_param) && all(isfield(joint_param, {'single_chan', ...
                        'all_chan'}))
    EEG = pop_jointprob(EEG, 1, 1:EEG.nbchan, joint_param.single_chan, ...
                        joint_param.all_chan, 0, 0);
end

if ~isempty(kurt_param) && all(isfield(kurt_param, {'single_chan', 'all_chan'}))
    EEG = pop_rejkurt(EEG, 1, 1:EEG.nbchan, kurt_param.single_chan, ...
                      kurt_param.all_chan, 0, 0);
end

fprintf('start superpose marked epochs\n');
EEG = eeg_rejsuperpose(EEG, 0, 1, 1, 1, 1, 1, 1, 1);
EEG = eeg_checkset(EEG);

% identify epoch
if ~isempty(EEG.reject.rejglobalE) && exist('thresh_chan', 'var')
    perBadEpochInChannels = sum(EEG.reject.rejglobalE, 2)/EEG.trials;
    rej_ch = find(perBadEpochInChannels > thresh_chan);
    if ~isempty(rej_ch)
        fprintf('---start: reject channels---\n');
        EEG = pop_select(EEG, 'nochannel', rej_ch);
        EEG = eeg_checkset(EEG);
        % identify epoch again
        EEG = rej_detect_epoch(EEG, thresh_param, trends_param, ...
                               spectra_param, joint_param, kurt_param, thresh_chan);
        EEG = eeg_checkset(EEG);
    end
end
