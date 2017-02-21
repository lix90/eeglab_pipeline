function paths = pick_paths(has_str)
% Pick paths with specified string(s).

if ischar(has_str)
    has_str = {has_str};
end

paths = [];
for i = 1:length(has_str)
    tmp = path;
    tmp_cell = regexp(tmp, ':', 'split');
    ind = cellfun(@any, strfind(tmp_cell, has_str{i}));
    paths = [paths, tmp_cell(ind)];
end
paths = unique(paths);
