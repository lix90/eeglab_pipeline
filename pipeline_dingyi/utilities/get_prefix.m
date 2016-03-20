function prefix = get_prefix(instr, pos)
% extract prefix by using delimiter ('_', '-', '.')
% input:
% 	instr: string or cell array
% 	pos: positive integer
% output:
% 	prefix: string or cell array 


% input check
if ~ischar(instr) && ~iscellstr(instr)
	error('instr must be string or cell string array')
end

% if ~isdouble(pos)
% 	error('pos must be positive integer')
% end

%
if ischar(instr)
	instr = {instr};
end

prefix = cell(size(instr));
for i = 1:numel(instr)
	ind1 = strfind(instr{i}, '-');
	ind2 = strfind(instr{i}, '.');
	ind3 = strfind(instr{i}, '_');
	ind = union(ind1, ind2);
	ind = union(ind, ind3);
	ind_need = ind(pos);
	prefix{i} = instr{i}(1:ind_need-1);
end
