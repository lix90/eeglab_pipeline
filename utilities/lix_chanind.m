% lix_chanind: find index of channel

function ind = lix_chanind(chan, chanlocs)
if nargin<2
    warning('use eeglab channel location file');
    chanlocs = EEG.chanlocs;
end

if ~iscell(chan)
    error('channel list must be cell array');
end

tmp = {chanlocs.labels};
ind = zeros(size(chan));
for i = 1:length(chan)
    ind(i) = find(strcmpi(tmp, chan{i}));
end


