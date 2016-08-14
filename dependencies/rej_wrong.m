function rej = rej_wrong(EEG, rightevent)

if nargin<2
	disp('parameters are not enough')
	return
end
if ~iscellstr(rightevent)
	disp('the second input must be cellstr')
	return
end

n = EEG.trials;
rightresp = zeros(1,n);
for i = 1:n
    tmp_event = EEG.epoch(1, i).eventtype;
    if any(cellfun(@isnumeric, tmp_event))
        tmp_event = cellfun(@(x) {num2str(x)}, tmp_event);
    end
    test = ismember(EEG.epoch(1,i).eventtype, rightevent);
    if any(test)
        rightresp(i) = 1;
    end
end
rej = find(~rightresp);
