function out = get_fnpart(filename, position)

if ischar(filename)
    filename = {filename};
end

pattern = '[_-.]';

fnparts = regexp(filename, pattern, 'split');
out = cellfun(@(x) x(position), fnparts);
