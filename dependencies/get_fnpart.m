function out = get_fnpart(filename, position)

if ischar(filename)
    filename = {filename};
end

pattern = '[^0-9a-zA-Z]';

fnparts = regexp(filename, pattern, 'split');
out = cellfun(@(x) x(position), fnparts);
