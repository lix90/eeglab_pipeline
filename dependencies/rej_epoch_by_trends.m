function EEG = rej_epoch_by_trends(EEG,slope,r2)

fprintf('************************************\n');
fprintf('Detect bad epochs by abnormal trends\n');
fprintf('************************************\n');

if isempty(slope)
    slope = 200;
end

if isempty(r2)
    r2 = 0.3;
end

ichan = find(pick_channel_types(EEG, {'eeg'}));
if isempty(ichan)
    ichan = 1:EEG.nbchan;
end

EEG = pop_rejtrend(EEG, 1, ichan, EEG.pnts, slope, r2, 1, 0, 0);
EEG = eeg_checkset(EEG);
% [EEG.reject.rejconst, EEG.reject.rejconstE] = ...
%     rejtrend(EEG.data, EEG.pnts, slope, r2, step);
% fprintf('%d/%d trial(s) marked for rejection\n', ...
%         length(find(EEG.reject.rejconst>0)), ...
%         EEG.trials);
% EEG = eeg_checkset(EEG);
