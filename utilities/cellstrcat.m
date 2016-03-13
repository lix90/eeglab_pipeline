% concatenate cell strings with delimiter
function outstr = cellstrcat(incellstr, del)

if isempty(incellstr); disp('input is empty'); return; end 
if ~iscellstr(incellstr); disp('input is not cellstr'); return; end 
if ~ischar(del); disp('varargin 2 is not a string array'); return; end

length_del = length(del);
num = numel(incellstr);

if num == 1
	strtmp = char(incellstr);
elseif num > 1
	strtmp = [];
	for i = 1:num
      if i == num
          strtmp = [strtmp, incellstr{i}];
      else
          strtmp = [strtmp, incellstr{i}, del];
      end
	end
end
outstr = strtmp;

