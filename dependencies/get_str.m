function outstr = get_str(instr, reg)
% extract id(s) of dataset names by regexp
% for more info: help regexp
% `outstr` is a cell string array

outstr = regexp(instr, reg, 'tokens');
if iscell(instr) && length(instr) > 1
    outstr = cellfun(@(x) x{:}, outstr);
end
