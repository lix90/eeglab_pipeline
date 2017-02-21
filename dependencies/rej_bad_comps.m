function EEG = rej_bad_comps(EEG, bads, confirm)

if ~exist('confirm', 'var')
    confirm = 0;  % do not confirm, just reject it.
end


if ~exist('bads', 'var')
    bads = [];  % reject all marked components
else
    if ~isnumeric(bads) && ~isinteger(bads)
        disp('Error: the 2nd argument must be numeric or integer array.');
        return;
    elseif ~any(size(bads)==1) && ndims(bads)~=2
        disp(['Error: the 2nd argument must be a numeric or an integer vector ' ...
              'array.']);
        return;
    end
end

EEG.etc.info.orig_num_comps = size(EEG.icaweights,1);
% rejecting
EEG = pop_subcomp(EEG, bads, confirm);
EEG.etc.info.bad_comps = bads;
EEG = eeg_checkset(EEG);


