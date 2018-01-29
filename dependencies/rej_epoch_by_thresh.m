function EEG = rej_epoch_by_thresh(EEG, low, up)

fprintf('************************************\n');
fprintf('Detect bad epochs by abnormal values\n');
fprintf('************************************\n');

if ~exist('low', 'var')
    low = -500;
end

if ~exist('up', 'var')
    up = 500;
end

ichan = find(pick_channel_types(EEG, {'eeg'}));
if isempty(ichan)
    ichan = 1:EEG.nbchan;
end

EEG = pop_eegthresh(EEG, 1, ichan, low, up, EEG.xmin, EEG.xmax, 0, 0);

% [~, rej_thresh, ~, rej_threshE] = eegthresh(EEG.data, ...
%                                             EEG.pnts, ...
%                                             1:EEG.nbchan, ...
%                                             low, up, ...
%                                             [EEG.xmin, EEG.xmax],...
%                                             EEG.xmin, EEG.xmax);
% rejthresh_tmp = zeros(1, EEG.trials);
% rejthresh_tmp(rej_thresh) = 1;
% EEG.reject.rejthresh = rejthresh_tmp;
% rejthreshE_tmp = zeros(EEG.nbchan, EEG.trials);
% rejthreshE_tmp(:, rej_thresh) = rej_threshE;
% EEG.reject.rejthreshE = rejthreshE_tmp;
EEG = eeg_checkset(EEG);
% fprintf('%d/%d trial(s) marked for rejection\n', ...
%         length(find(EEG.reject.rejthresh)), ...
%         EEG.trials);
