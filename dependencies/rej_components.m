function [EEG] = rej_components(EEG, bads, confirm)

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

EEG.etc.original_number_of_comps = size(EEG.icaweights,1);

if ~isempty(bads)
    EEG = pop_subcomp(EEG, bads, confirm);
end
EEG.etc.bad_comps = bads;
EEG = eeg_checkset(EEG);


