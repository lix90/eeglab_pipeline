function id = get_id(filename, sep)

if ~exist('sep', 'var')
    sep = '[^a-z0-9]';
    pos = 0;
else
    pos = 1;
end

id = [];
outstrs = regexp(filename, sep, 'split');
if pos == 1
    id = cellfun(@(x) x{pos}, outstrs, 'uniformoutput', false);
elseif pos == 0
    numstrs = cellfun(@(x) length(x), outstrs);
    minstr = min(numstrs);
    for i = 1:minstr
        tmpstr = cellfun(@(x) x{i}, outstrs, 'uniformoutput', false);
        id = strcat(id, tmpstr);
        if length(id) == length(unique(id))
            break
        end
    end
end
