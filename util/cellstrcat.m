% concatenate cell strings with delimiter
function outstr = cellstrcat(incellstr, del)

if isempty(incellstr); disp('input cellstr is empty'); return; end 
if ~iscellstr(incellstr); disp('input must be cellstr'); return; end 
if ~ischar(del); disp('delimiter must be string'); return; end

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

