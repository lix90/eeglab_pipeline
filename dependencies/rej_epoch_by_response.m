function rej = rej_epoch_by_response(EEG, wrong_resp) 

if nargin<2
	disp('parameters are not enough');
	return
end
if ~iscellstr(wrong_resp)
	disp('the second input must be cellstr');
	return
end

n = EEG.trials;
wrong = zeros(1,n);
for i = 1:n
    tmp_event = EEG.epoch(1, i).eventtype;
    % if any(cellfun(@isnumeric, tmp_event))
    %     tmp_event = cellfun(@(x) {num2str(x)}, tmp_event);
    % end
    if any(ismember(tmp_event, wrong_resp))
        wrong(i) = 1;
    end
end
rej = find(wrong);
