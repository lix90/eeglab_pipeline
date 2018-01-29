function rej = rej_epoch_by_rt(EEG, resp, timewin)

if ~iscellstr(resp)
    disp('resp must be cellstr');
    return;
end

if length(timewin)~=2
    disp('timewin must have two elements');
    return;
end

if abs(max(timewin))<10
   timewin = timewin*1000; 
end

ntrials = EEG.trials;
rej = zeros(1, ntrials);
for i = 1:numel(resp)
    rt = eeg_getepochevent(EEG, 'type', resp{i}, 'timewin', timewin);
    rt = isnan(rt);
    rej = rt+rej;
end
rej = logical(rej);
