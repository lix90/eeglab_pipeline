function rej = rej_rt(EEG, resp, timewin)

if ~iscellstr(resp)
    disp('resp must be cellstr');
    return;
end

if length(timewin)~=2
    disp('timewin must have two elements');
    return;
end

ntrials = EEG.trials;
rej = zeros(1, ntrials);
for i = 1:numel(resp)
    rt = eeg_getepochevent(EEG, 'type', resp{i}, 'timewin', timewin);
    rt = isnan(rt);
    rej = rt+rej;
end
rej = logical(rej);
